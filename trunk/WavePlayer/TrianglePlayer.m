//
//  TrianglePlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on 6/19/07.
//  Copyright 2007 Unsaturated Studios. All rights reserved.
//

#import "TrianglePlayer.h"


@implementation TrianglePlayer

-(id)init {
  if(nil == (self = [super init]))
    return nil;
  
  previousSquare = 0.0;
  curPolarity = 1;
  return self;
}

-(void)fillBuffer:(void*)buffer withFrames:(UInt32)numFrames ofStreamDescription:(AudioStreamBasicDescription)bufferDescription {
  UInt32 frameNumber;
  UInt32 channelNumber;
  
  if(!buffer)return;
  for(frameNumber = 0; frameNumber < numFrames; frameNumber++) {
    SInt16  intFunctValue;
    SInt16* currentFrame;
    Float32 currentFrequency;
    double  functionIncrement;
    double  currentFunctValue;
    
    //In the case of triangle wave we use a sawtooth an octave up and flip the waveform
    // on the ramp reset.
    currentFrequency = freqBuffer[frameNumber] * 2;
    functionIncrement = (double)currentFrequency / (double)bufferDescription.mSampleRate;
    currentFunctValue = ((curWavePosition * 2.0) - 1.0);
    
    if(isAnalog) {
      double  currentSquare = currentFunctValue * currentFunctValue;
      double  currentDerivative = currentSquare - previousSquare;
      
      previousSquare = currentSquare;
      
      currentDerivative *= bufferDescription.mSampleRate / 
      ((4 * currentFrequency) * (1 - currentFrequency / bufferDescription.mSampleRate));
      
      intFunctValue = (SInt16)(currentDerivative * kAmplitude * (double)(1 << (bufferDescription.mBitsPerChannel - 2)));      
    }
    else {
      intFunctValue = (SInt16)(currentFunctValue * kAmplitude * (double)(1 << (bufferDescription.mBitsPerChannel - 2)));
    }
    curWavePosition = curWavePosition + functionIncrement;
    while(curWavePosition >= 1.0) {
      curWavePosition -= 1.0;
      curPolarity *= -1;
    }
    intFunctValue *= (SInt16)curPolarity;
    currentFrame = ((SInt16*)buffer) + (frameNumber * bufferDescription.mChannelsPerFrame);
    for(channelNumber = 0; channelNumber < bufferDescription.mChannelsPerFrame; channelNumber++)
      *(currentFrame + channelNumber) = intFunctValue;
  }
}
@end
