//
//  FunctionPlayer.h
//  SineSweeper

/*  
 *  The functionPlayer object provides an easy abstraction for function-generating objects
 *  conforming to the FunctionGenerator protocol.  This code is boring, and I don't want to 
 *  rewrite it...  This is pretty simple right now, it will have to change to be more
 *  general about the audio output.
 */
//
//  Created by Mark Pauley on Sat Jun 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WaveGenerator/WaveGenerator.h>
#import <CRAudioUnits/CRAudioConverter.h>
#import <CRAudioUnits/CRDefaultAudioOutput.h>


@interface FunctionPlayer : NSObject {
  //SampleRate
  Float64 sourceSampleRate;
  Float64 outputSampleRate;
  UInt32  numInputFrames;
  
  //Format
  // TODO: more info
  UInt32 theFormatID;
  UInt32 theFormatFlags;
  
  //Stream descriptions, necessary for CoreAudio registration
  AudioStreamBasicDescription sourceStreamFormat;
  AudioStreamBasicDescription destStreamFormat;
  
  //AudioUnit wrappers
  CRAudioConverter* converter;
  CRDefaultAudioOutput* theOutputUnit;
  
  
  //the timestamp of the last render message
  AudioTimeStamp timeStamp;
  
  void*  playBuffer;
  UInt32 playBufferSize;
  
  WaveGenerator* synthesizer;
}

//controls
- (void) startPlaying;
- (void) stopPlaying;

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




-(void)setTimeStamp:(const AudioTimeStamp*)timeStamp;
-(const AudioTimeStamp*)getTimeStamp;

@end
