
//
//  FunctionPlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on Sat Jun 26 2004.
//  Copyright (c) 2004 Mark Pauley (mpauley@mac.com). All rights reserved.
//

#import "FunctionPlayer.h"

//TODO: move these to a nicer location or make em #defines... for christs sake
const UInt32 numBytesInAPacket = 4;
const UInt32 numFramesPerPacket = 1; // this shouldn't change
const UInt32 numBytesPerFrame = 4; //
const UInt32 numChannelsPerFrame = 2;
const UInt32 numBitsPerChannel = 16;

// These static C functions are needed for stubbing... 
// This makes the rest of the code much cleaner.  Let me know if you find a better way.

// This is the proc that supplies the data to the AudioConverterFillBuffer call
// The FillBuffer call is used to fill the buffer from the OutputUnit's render slice call
static OSStatus bufferFillStub (AudioConverterRef			inAudioConverter,
							    UInt32*						outDataSize,
							    void**						outData,
							    void*						inUserData)
{
  return [inUserData fillBuffer:outData ofSize:outDataSize withConverter:inAudioConverter];  
}


/*
 *Stub functions, these are necessary to minimize the static code...
 * these are not going to be seen by the subclasses anyhow.
 */

static OSStatus	renderStub(void *inRefCon, AudioUnitRenderActionFlags inActionFlags,
						   const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
						   AudioBuffer *ioData)
{
  
  FunctionPlayer* player = inRefCon;
  
  [player setTimeStamp: inTimeStamp];
  
  [player setFillToBuffer: ioData
					onBus: inBusNumber
				withFlags: inActionFlags];
  
  OSStatus converterStatus = noErr;
  //do I just set up the buffer-filling callback?
  if(converterStatus != noErr)
	return converterStatus;
  
  return noErr;
}


/*property change callback*/
static void streamPropertyListenerStub (void *inRefCon,
										AudioUnit ci,
										AudioUnitPropertyID inID,
										AudioUnitScope inScope,
										AudioUnitElement inElement)
{
  FunctionPlayer* player = inRefCon;
  [player propertyChanged:inID ofUnit:ci inScope:inScope inElement:inElement];  
}


@implementation FunctionPlayer

-(id)init
{
  if(nil == (self = [super init]))
	return nil;
  
  /*setup the format data*/
  theFormatID = kAudioFormatLinearPCM;
  theFormatFlags = 
	kLinearPCMFormatFlagIsSignedInteger
	| kLinearPCMFormatFlagIsBigEndian
	| kLinearPCMFormatFlagIsPacked;
  
  
  return self;
}

- (void) startPlaying
{
  struct AudioUnitInputCallback callback;
  UInt32 aStreamSize;
  
  /*Warning, glaven format info ahead!*/
  sourceStreamFormat.mSampleRate       = sourceSampleRate;		//	the sample rate of the audio stream
  sourceStreamFormat.mFormatID         = theFormatID;			//	the specific encoding type of audio stream
  sourceStreamFormat.mFormatFlags      = theFormatFlags;		//	flags specific to each format
  sourceStreamFormat.mBytesPerPacket   = numBytesInAPacket;
  sourceStreamFormat.mFramesPerPacket  = numFramesPerPacket;
  sourceStreamFormat.mBytesPerFrame    = numBytesPerFrame;
  sourceStreamFormat.mChannelsPerFrame = numChannelsPerFrame;
  sourceStreamFormat.mBitsPerChannel   = numBitsPerChannel;
  
  // initialize the output unit
  theOutputUnit = [CRDefaultAudioOutput open];
  [theOutputUnit retain];
  [theOutputUnit initialize];
  
  // set the callback function
  callback.inputProc = renderStub;
  callback.inputProcRefCon = (void*)self;
  [theOutputUnit setInputCallback: &callback];
  
  // set up the data conversion from SInt16 to Float32
  // ** If we told the DefaultOutputUnit what format we were
  // working with, it could automatically do the conversion (
  // See SinPlayerWithImplicitConversion) **
  aStreamSize = sizeof(AudioStreamBasicDescription);
  verify_noerr([theOutputUnit getInputStreamFormatInto: &destStreamFormat]);
  outputSampleRate = destStreamFormat.mSampleRate;
  converter = [CRAudioConverter crAudioConverterFrom: &sourceStreamFormat
												  to: &destStreamFormat];
  [converter retain];
  
  // DEBUG
  printf("Manually converting source from %f to %f\n", sourceStreamFormat.mSampleRate, destStreamFormat.mSampleRate);
  
  // add a property listener so we can react to changes in the format
  verify_noerr([theOutputUnit addTo: kAudioUnitProperty_StreamFormat
				   propertyListener: streamPropertyListenerStub
							   with: (void*)self]);
  
  // Start the rendering
  verify_noerr([theOutputUnit start]);
}

-(OSStatus)setFillToBuffer: (AudioBuffer*)ioData
					 onBus: (UInt32)inBusNumber
				 withFlags: (AudioUnitRenderActionFlags)inActionFlags
{
  
  OSStatus converterErr = noErr;
  printf("setting the converter's buffer filling callback: %p\n", bufferFillStub);
  /*need to see just what's going on here...*/
  converterErr = [converter fillBufferUsing: bufferFillStub
								 forwarding: self
									   size: &(ioData->mDataByteSize)
									   into: ioData->mData];
  return converterErr;
}

-(OSStatus)fillBuffer: (void**)outData 
			   ofSize: (UInt32*)outDataSize 
		withConverter: (AudioConverterRef)inAudioConverter
{
  
  if(*outDataSize != playBufferSize && playBuffer)
  {
	free(playBuffer);
	playBuffer = nil;
	/*
	 I might want to be setting the converter, as opposed to vice versa, 
	 but this seems good right now
	 */
	playBufferSize = *outDataSize;
  }
  
  if(!playBuffer)
	playBuffer = malloc(playBufferSize);
  
  if(!playBuffer)return -1;
  
  *outData = playBuffer;
  
  //bzero(playBuffer, playBufferSize);
  printf("<%p> fillBuffer\nBuffer: %p\nSize: %ld\nConverter: %p\n",
		 self, *outData, *outDataSize, inAudioConverter);
  
  return noErr;
}



-(void)setTimeStamp:(const AudioTimeStamp*)timeStamp
{
  if(timeStamp != nil)
	memcpy(&lastRenderTimeStamp, timeStamp, sizeof(AudioTimeStamp));
}

-(const AudioTimeStamp*)getTimeStamp
{
  return (const AudioTimeStamp*)&lastRenderTimeStamp;
}
@end
