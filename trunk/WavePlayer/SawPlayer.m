//
//  SawPlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on 5/30/07.
//  Copyright 2007 Unsaturated Studios. All rights reserved.
//

#import "SawPlayer.h"


@implementation SawPlayer

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
		
		currentFrequency = freqBuffer[frameNumber];
		functionIncrement = (double)currentFrequency / (double)bufferDescription.mSampleRate;
		
		currentFunctValue = (curWavePosition * 2.0) - 1.0;
		intFunctValue = (SInt16)(currentFunctValue * (double)(1 << (bufferDescription.mBitsPerChannel - 2)));
		curWavePosition = fmod((curWavePosition + functionIncrement), 1);
		
		currentFrame = ((SInt16*)buffer) + (frameNumber * bufferDescription.mChannelsPerFrame);
		for(channelNumber = 0; channelNumber < bufferDescription.mChannelsPerFrame; channelNumber++)
			*(currentFrame + channelNumber) = intFunctValue;
		
	}

}

@end
