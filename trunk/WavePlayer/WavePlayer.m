//
//  WavePlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WavePlayer.h"
#include <stdio.h>
#include <math.h>
#include <errno.h>
#include <strings.h>


#define kAudioFormatFlags  kAudioFormatFlagIsSignedInteger\
                         | kAudioFormatFlagsNativeEndian\
						 | kAudioFormatFlagIsPacked


//TODO: move these to a nicer location or make em #defines... for christs sake
const UInt32 kSourceSampleRate = 44100.0;/*hi-fi n stuff!*/
const UInt32 kNumChannels = 2; //stairy-airy oh!
const UInt32 kNumBitsPerChannel = 16;

/* That bufferFillStub is based on a deprecated API... don't want to use that. */
static OSStatus complexBufferFillStub(AudioConverterRef inAudioConverter, 
							   UInt32* ioNumberDataPackets, 
							   AudioBufferList* ioData, 
							   AudioStreamPacketDescription** outDataPacketDescription, 
							   void* inUserData)
{
  //printf("filling complex buffer\n");
  [(WavePlayer*)inUserData fillBufferList: ioData
					  requestedPacketsRef: ioNumberDataPackets
				  packetDescriptionHandle: outDataPacketDescription];
  //the outDataPacketDescription is only needed for vbr conversion
  return noErr;
}



/*
 * Stub functions, these are necessary to minimize the static code...
 * these are not going to be seen by the subclasses anyhow.
 */

static OSStatus	renderStub(void *player, 
						   AudioUnitRenderActionFlags inActionFlags,
						   const AudioTimeStamp *inTimeStamp,
						   UInt32 inBusNumber,
						   UInt32 inNumFrames,
						   AudioBufferList *ioData)
{
  //TODO: check the runtime-type of player
  //printf("Render\n");
  [(WavePlayer*)player setTimeStamp: inTimeStamp];
  
  verify_noerr([(WavePlayer*)player renderToBufferList: ioData
											 numFrames: inNumFrames
												 onBus: inBusNumber
											 withFlags: inActionFlags]);
  
  return noErr;
}	  

/*property change callback*/
static void streamPropertyListenerStub (void *inRefCon,
										AudioUnit ci,
										AudioUnitPropertyID inID,
										AudioUnitScope inScope,
										AudioUnitElement inElement)
{
  WavePlayer* player = inRefCon;
  [player propertyChanged:inID 
				   ofUnit:ci 
				  inScope:inScope 
				inElement:inElement];
  
}


@implementation WavePlayer

-(id)init
{
  if(nil == (self = [super init]))
	return nil;
  
  /*Warning, glaven format info ahead!*/
  sourceStreamFormat.mSampleRate       = kSourceSampleRate;		//	the sample rate of the audio stream
  sourceStreamFormat.mFormatID         = kAudioFormatLinearPCM; //	the specific encoding type of audio stream
  sourceStreamFormat.mFormatFlags      = kAudioFormatFlags;		//	flags specific to each format
  sourceStreamFormat.mBytesPerPacket   = sizeof(SInt16) * kNumChannels;
  sourceStreamFormat.mFramesPerPacket  = 1; //keep frame == packet, should research the diff between frames and packets
  sourceStreamFormat.mBytesPerFrame    = sourceStreamFormat.mBytesPerPacket / sourceStreamFormat.mFramesPerPacket;
  sourceStreamFormat.mChannelsPerFrame = kNumChannels;
  sourceStreamFormat.mBitsPerChannel   = kNumBitsPerChannel;
  
  curRealFreq = 4000.0;
  curPlayingFreq = curRealFreq;
  
  playBuffer = NULL;
  playBufferSize = 0;
  curSampleInterval = 0;
  freqUpdateInterval = 1;
  functionIncrement = (double)curPlayingFreq / (double)sourceStreamFormat.mSampleRate;
  
  ComponentDescription desc;
  desc.componentType = kAudioUnitType_Output;
  desc.componentSubType = kAudioUnitSubType_DefaultOutput;
  desc.componentManufacturer = kAudioUnitManufacturer_Apple;
  desc.componentFlags = 0;
  desc.componentFlagsMask = 0;
  
  Component comp = FindNextComponent(NULL, &desc);
  if(comp == NULL) { 
	  NSLog(@"FindNextComponent failed!\n");
	  //bail?
  }
  OSStatus err;
  err = OpenAComponent(comp, &myAudioUnit);
  if(err != noErr) {
	  NSLog(@"OpenAComponent failed!\n");
	  //bail?
  }
  AudioUnitInitialize(myAudioUnit);
  AudioUnitReset(myAudioUnit,
				 kAudioUnitScope_Input,
				 0);
  AudioUnitUninitialize(myAudioUnit);
  return self;
}

-(void)startPlaying
{
  AURenderCallbackStruct renderCallback;
  UInt32 aStreamSize;
  

  
  // set the callback function
  renderCallback.inputProc = (void*)renderStub;
  renderCallback.inputProcRefCon = (void*)self;
    
  verify_noerr( AudioUnitSetProperty(myAudioUnit,
									 kAudioUnitProperty_SetRenderCallback,
									 kAudioUnitScope_Input,
									 0,
									 &renderCallback,
									 sizeof(AURenderCallbackStruct)) );
  
  
  verify_noerr( AudioUnitSetProperty(myAudioUnit,
									 kAudioUnitProperty_StreamFormat,
									 kAudioUnitScope_Input,
									 0,
									 &sourceStreamFormat,
									 sizeof(AudioStreamBasicDescription)) );
  verify_noerr( AudioUnitInitialize(myAudioUnit));


  aStreamSize = sizeof(AudioStreamBasicDescription);
  UInt32 destStreamFormatSize;

  verify_noerr( AudioUnitGetProperty(myAudioUnit,
									 kAudioUnitProperty_StreamFormat,
									 kAudioUnitScope_Input,
									 0,
									 &destStreamFormat,
									 &destStreamFormatSize) );
 
  //verify_noerr( AudioConverterNew(&sourceStreamFormat,
//								  &destStreamFormat,
//								  &audioConverter) );  
  
  curWavePosition = 0;
  curRealFreq = startFreq;
  
  verify_noerr(AudioOutputUnitStart(myAudioUnit));
}

-(void)stopPlaying
{
  verify_noerr(AudioOutputUnitStop(myAudioUnit));
  verify_noerr(AudioUnitUninitialize(myAudioUnit));
}  
  

-(OSStatus)setFillToBuffer: (AudioBuffer*)ioData
					 onBus: (UInt32)inBusNumber
				 withFlags: (AudioUnitRenderActionFlags)inActionFlags
{
  
  OSStatus converterErr = noErr;
  /* should probably alloc the ioData->mData here*/
  if(ioData->mDataByteSize != playBufferSize && playBuffer)
  {
	free(playBuffer);
	playBuffer = nil;

	
	/*
	 * I might want to be setting the converter, as opposed to vice versa, 
	 * but this seems good right now
	 */
	playBufferSize = ioData->mDataByteSize;
  }
  
  if(!playBuffer)
	playBuffer = malloc(playBufferSize);
	
  if(!playBuffer)
	return -1;
  
  ioData->mData = playBuffer;

  //[self fillBuffer:playBuffer withFrames: ofStreamDescription:sourceStreamFormat];

  return converterErr;
}

/*
 * Abstract away the sample-wise frequency value determination
 *  to allow for decoupling of waveform and frequency update.
*/
-(void)createFrequencyEnvelope:(Float32*)freqEnvelopeBuffer ofSize:(UInt32)numFrames {
	UInt32 frameNumber;
	double freqMultValue = pow(2, 1.0 / (sourceStreamFormat.mSampleRate * sweepRate)); 
	
	for(frameNumber = 0; frameNumber < numFrames; frameNumber++) {
		//FIXME: I'm possibly losing some wrap here.
		//  consider this more, the wrap-interpolation seems non-trivial
		if(startFreq < endFreq) {
			curRealFreq *= freqMultValue;
			if(curRealFreq > endFreq)curRealFreq = startFreq;
		}
		else {
		  curRealFreq /= freqMultValue;
		  if(curRealFreq < endFreq)curRealFreq = startFreq;
		}
		curSampleInterval++;
		if(curSampleInterval >= freqUpdateInterval) {
			curSampleInterval -= freqUpdateInterval;
			curPlayingFreq = curRealFreq;
		}
		freqEnvelopeBuffer[frameNumber] = curPlayingFreq;
	}
}

-(OSStatus)renderToBufferList: (AudioBufferList*) bufferList
					numFrames: (UInt32) numFrames
						onBus: (UInt32) inBusNumber
					withFlags: (AudioUnitRenderActionFlags) inActionFlags 
{
	
	/*
	 * Use a converter to avoid needing to know the output format.
	 */
	
	UInt32 packetsRendered;
	
	//numFrames = bufferList->mBuffers[0].mDataByteSize / destStreamFormat.mBytesPerFrame;
	
	if(!numFrames)return noErr;
	packetsRendered = numFrames / sourceStreamFormat.mFramesPerPacket;
	
	if(playBufferSize < numFrames * sourceStreamFormat.mBytesPerFrame) {
      if(playBuffer)
          free(playBuffer);
    
      if(freqBuffer)
        free(freqBuffer);
      
      playBufferSize = numFrames * sourceStreamFormat.mBytesPerFrame;
      playBuffer = malloc(playBufferSize);
      freqBuffer = malloc(numFrames * sizeof(Float32));
	}
	
	[self fillBufferList: bufferList
	 requestedPacketsRef: &packetsRendered
 packetDescriptionHandle: nil];
	
	return noErr;
}

-(void)  fillBufferList: (AudioBufferList*)bufferList
	requestedPacketsRef: (UInt32*)ioNumberDataPackets
packetDescriptionHandle: (AudioStreamPacketDescription**)outDataPacketDescription
{
  int curBufferNum;
  UInt32 numFrames = *ioNumberDataPackets * sourceStreamFormat.mFramesPerPacket;
  [self createFrequencyEnvelope:freqBuffer ofSize:numFrames];
  [self fillBuffer:playBuffer 
		withFrames:numFrames
	ofStreamDescription:sourceStreamFormat];
	
  for(curBufferNum = 0; curBufferNum < bufferList->mNumberBuffers; curBufferNum++)
  {
	bufferList->mBuffers[curBufferNum].mDataByteSize = playBufferSize;
	bufferList->mBuffers[curBufferNum].mData = playBuffer;
  }
  *ioNumberDataPackets = playBufferSize / sourceStreamFormat.mBytesPerPacket;
}

-(void)setTimeStamp:(const AudioTimeStamp*)newTimeStamp
{
  if(newTimeStamp != nil)
	timeStamp = *newTimeStamp;
}

-(void)setStartFreq:(double)newStartFreq
{
  startFreq = newStartFreq;
}

-(void)setEndFreq:(double)newEndFreq
{
  endFreq = newEndFreq;
}

-(void)setSweepRate:(double)newSweepRate
{
  sweepRate = newSweepRate;
}

-(void)setFreqUpdateInterval:(unsigned int)samples
{
	freqUpdateInterval = samples;
}

-(const AudioTimeStamp)getTimeStamp
{
  return (const AudioTimeStamp)timeStamp;
}

-(void)propertyChanged:(AudioUnitPropertyID)inID 
				ofUnit:(AudioUnit)ci 
			   inScope:(AudioUnitScope)inScope 
			 inElement:(AudioUnitElement)inElement
{
  NSLog(@"Property Changed\n AudioUnit:%p\n PropertyID: %d\n inScope: %d\n inElement: %d",
		&ci, inID, inScope, inElement);
}

-(void)fillBuffer:(void*)buffer withFrames:(UInt32)numFrames ofStreamDescription:(AudioStreamBasicDescription)bufferDescription {

}

@end
