//
//  PulsePlayer.m
//  SineSweeper
//
//  Created by Mark Pauley on 6/3/07.
//  Copyright 2007 Unsaturated Studios. All rights reserved.
//

#import "PulsePlayer.h"


@implementation PulsePlayer
	-(id)init {
		if(nil == (self = [super init]))
			return nil;
		dutyCycle = 0.5;
		return self;
	}
	
	// I make a pulse by subtraction of two sawtooth waves.  The phase offset determines the duty cycle.
	// the pseudo-analog algo I'm using requires sawtooth waves.
	-(void)fillBuffer:(void*)buffer withFrames:(UInt32)numFrames ofStreamDescription:(AudioStreamBasicDescription)bufferDescription {
		static double previousPosSquare = 0;
		static double previousNegSquare = 0;
		
		UInt32 frameNumber;
		UInt32 channelNumber;
		
		if(!buffer)return;
		
		for(frameNumber = 0; frameNumber < numFrames; frameNumber++) {
			SInt16	intFunctValue;
			SInt16* currentFrame;
			Float32 currentFrequency;
			double  functionIncrement;
			double	currentPosFunctValue;
			double	currentNegFunctValue;

			currentFrequency = freqBuffer[frameNumber];
			functionIncrement = (double)currentFrequency / (double)bufferDescription.mSampleRate;
			
			currentPosFunctValue = ((fmod((curWavePosition + dutyCycle), 1.0) * 2.0) - 1.0);
			//
			currentNegFunctValue = ( (curWavePosition * 2.0) - 1.0);
			if(isAnalog) {
				double scaleValue = bufferDescription.mSampleRate /
					((4 * currentFrequency) * (1 - currentFrequency / bufferDescription.mSampleRate));
				double currentPosSquare = currentPosFunctValue * currentPosFunctValue;
				double currentNegSquare = currentNegFunctValue * currentNegFunctValue;
				double currentPosDerivative = (currentPosSquare - previousPosSquare);
				double currentNegDerivative = (currentNegSquare - previousNegSquare);
					
				
				previousPosSquare = currentPosSquare;
				previousNegSquare = currentNegSquare;
				currentPosDerivative *= scaleValue;
				currentNegDerivative *= scaleValue;
				intFunctValue = (SInt16)((currentPosDerivative - currentNegDerivative) * (double)kAmplitude * 
					(double)(1 << (bufferDescription.mBitsPerChannel - 2)));
			}
			else {
				intFunctValue = (SInt16)((currentPosFunctValue - currentNegFunctValue) * (double)kAmplitude *
					(double)(1 << (bufferDescription.mBitsPerChannel - 2)));
			}
			curWavePosition = fmod((curWavePosition + functionIncrement), 1.0);
			
			currentFrame = ((SInt16*)buffer) + (frameNumber * bufferDescription.mChannelsPerFrame);
			for(channelNumber = 0; channelNumber < bufferDescription.mChannelsPerFrame; channelNumber++)
				*(currentFrame + channelNumber) = intFunctValue;
		}
	}

@end
