//
//  WaveGenerator.h
//
//  Created by Mark Pauley on Sat Jun 26 2004.
//  Copyright (c) 2004 Mark Pauley (mpauley@mac.com). All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WaveGenerator

-(OSStatus)fillBuffer:  (void*)buffer
		  numChannels:    (int)numChannels
	   bytesPerSample:    (int)sampleSize
		   numSamples: (UInt32)numSamples;

/*Frequency in hz*/
-(void)setFrequency: (UInt32)frequency;
-(UInt32)getFrequency;

/*
 * Amplitude in percent of total amplitude...
 * thinking this should be based on power though.
 * Maybe there will be a separate accessor;
*/
-(void)setAmplitude: (float)amplitude;
-(float)getAmplitude;


@end
