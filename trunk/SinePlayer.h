//
//  SinePlayer.h
//  SineSweeper
//
//  Created by Mark Pauley on Mon Jun 14 2004.
//  Copyright (c) 2004 Unsaturated Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <AudioToolbox/AudioConverter.h>
#include <CoreAudio/CoreAudio.h>
#include <AudioUnit/AudioUnit.h>

/*
*  TODO: abstract this to allow for all types of waveform players (Sine, Pulse, Triangle, Saw)
*    as well as allowing for several different types of modulation waveform.
*/

@interface SinePlayer : NSObject {
  //Frequency information
  double startFreq;
  double endFreq;
  double curRealFreq;
  double curPlayingFreq;
  double sweepRate;
  double freqIncrement;
  double functionIncrement;
  unsigned int freqUpdateInterval;
  unsigned int curSampleInterval;
  BOOL   modulationIsLogarithmic;

  /*Stream descriptions, necessary for CoreAudio registration*/
  AudioStreamBasicDescription sourceStreamFormat;
  AudioStreamBasicDescription destStreamFormat;

  AudioConverterRef audioConverter;
  // myAudioUnit is the output unit.
  AudioUnit         myAudioUnit;

  double curWavePosition;

  /*the timestamp of the last render message*/
  AudioTimeStamp timeStamp;

  SInt16*   playBuffer;
  UInt32    playBufferSize;
  
  Float32*  freqBuffer;
  
 }

//controls
-(void)startPlaying;
-(void)stopPlaying;

-(void)setStartFreq:(double)newStartFreq;
-(void)setEndFreq:(double)newEndFreq;


//fills playBuffer
-(void)fillBuffer;

/* 
* For setting the buffer-fill callback.							
* This gets called once when the startPlaying method gets called.     
* Though I should probably experiment and make sure this is the case.
* This most likely will not be visible to the subclasses, though it could be
* made available for possible efficiency increases.
*/
-(OSStatus)setFillToBuffer: (AudioBuffer*)ioData    
					 onBus: (UInt32)inBusNumber
				 withFlags: (AudioUnitRenderActionFlags)inActionFlags;


/*
 * Actually fills the buffer.  I believe we maybe allowed to change the location of outdata, 
 * but this is still unresolved.  Subclasses might over-ride this one.
 */
-(OSStatus)fillBuffer: (void**)outData 
			   ofSize: (UInt32*)outDataSize 
		withConverter: (AudioConverterRef)inAudioConverter;


/*
 * Called by our render-callback stub.  This is invoked when CoreAudio is getting
 * hungry.  Fill the buffer with sound values.  
 * bufferlist is described by the destination stream discriptor: destStreamFormat.
 */
-(OSStatus)renderToBufferList: (AudioBufferList*) bufferList
					numFrames: (UInt32) numFrames
						onBus: (UInt32) inBusNumber
					withFlags: (AudioUnitRenderActionFlags) inActionFlags;


/*
 * Called by our audioConverter call-back stub.  
 * This is invoked when the audioConverter needs more data.
 * AudioBufferList is described by sourceStreamFormat.
 */
-(void)  fillBufferList: (AudioBufferList*)bufferList
		requestedPacketsRef: (UInt32*)ioNumberDataPackets
	packetDescriptionHandle: (AudioStreamPacketDescription**)outDataPacketDescription;

/*
 * Called by property change callback stub.
 */
-(void)propertyChanged:(AudioUnitPropertyID)inID 
				ofUnit:(AudioUnit)ci 
			   inScope:(AudioUnitScope)inScope 
			 inElement:(AudioUnitElement)inElement;


-(void)setTimeStamp:(const AudioTimeStamp*)timeStamp;
-(const AudioTimeStamp)getTimeStamp;
-(void)setSweepRate:(double)newSweepRate;

-(void)setFreqUpdateInterval:(unsigned int)samples;

@end
