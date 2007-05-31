//
//  SinePlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on Mon Jun 14 2004.
//  Copyright (c) 2004 Unsaturated Audio. All rights reserved.
//

#import "SinePlayer.h"

@implementation SinePlayer

-(void)fillBuffer {
  UInt32  frameNumber;
  UInt32  channelNumber;
  double  currentFunctValue;
  double  freqMultValue;
  UInt32  numFrames;
  
  if(!playBuffer)
  {
	playBuffer = malloc(playBufferSize);
	bzero(playBuffer, playBufferSize);
  }
  
  //I store the input to the sine function, 
  // this just seems like the cleaner way to do it
  freqMultValue = pow(2, 1.0 / (sourceStreamFormat.mSampleRate * sweepRate)); 
  /*samples per cycle*/
  
  numFrames = playBufferSize / sourceStreamFormat.mBytesPerFrame;
  [self createFrequencyEnvelope:freqBuffer ofSize:numFrames];

  for(frameNumber = 0; frameNumber <  numFrames; frameNumber++)
  {
	SInt16    intFunctValue;
	SInt16*   currentFrame;
    Float32   currentFrequency;

    currentFrequency = freqBuffer[frameNumber];
    functionIncrement = (double)currentFrequency / (double)sourceStreamFormat.mSampleRate;
	/* generate the current frame, and increment the function position */
	currentFunctValue = sin(curWavePosition * 2 * PI) * kAmplitude;

	/* normalize the wave to our resolution */
	intFunctValue = (SInt16)(currentFunctValue * (double)(1 << (sourceStreamFormat.mBitsPerChannel - 2)));
	/*this method of updating the position causes an accumulation of error*/
	curWavePosition = fmod((curWavePosition + functionIncrement), 1);
	
	currentFrame = playBuffer + (frameNumber * sourceStreamFormat.mChannelsPerFrame);
	
	for(channelNumber = 0; channelNumber < sourceStreamFormat.mChannelsPerFrame; channelNumber++)
	  *(currentFrame + channelNumber) = intFunctValue;
	
  }
  
}

@end
