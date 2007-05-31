//
//  SinePlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on Mon Jun 14 2004.
//  Copyright (c) 2004 Unsaturated Audio. All rights reserved.
//

#import "SinePlayer.h"

@implementation SinePlayer

-(void)fillBuffer:(void*)buffer withFrames:(UInt32)numFrames ofStreamDescription:(AudioStreamBasicDescription)bufferDescription {
  UInt32  frameNumber;
  UInt32  channelNumber;
  double  currentFunctValue;
  double  freqMultValue;
  
  if(!buffer)return;
  
  //precompute the frequency ahead of time (perhaps this should go into the caller?
  

  for(frameNumber = 0; frameNumber <  numFrames; frameNumber++) {
	SInt16    intFunctValue;
	SInt16*   currentFrame;
    Float32   currentFrequency;

    currentFrequency = freqBuffer[frameNumber];
    functionIncrement = (double)currentFrequency / (double)bufferDescription.mSampleRate;
	/* generate the current frame, and increment the function position */
	currentFunctValue = sin(curWavePosition * 2 * PI) * kAmplitude;

	/* normalize the wave to our resolution */
	intFunctValue = (SInt16)(currentFunctValue * (double)(1 << (bufferDescription.mBitsPerChannel - 2)));
	/*this method of updating the position causes an accumulation of error*/
	curWavePosition = fmod((curWavePosition + functionIncrement), 1);
	
	currentFrame = ((SInt16*)buffer) + (frameNumber * bufferDescription.mChannelsPerFrame);
	
	for(channelNumber = 0; channelNumber < bufferDescription.mChannelsPerFrame; channelNumber++)
	  *(currentFrame + channelNumber) = intFunctValue;
	
  }
  
}

@end
