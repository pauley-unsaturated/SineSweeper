//
//  SinePlayer.h
//  SineSweeper
//
//  Created by Mark Pauley on Mon Jun 14 2004.
//  Copyright (c) 2004 Unsaturated Studios. All rights reserved.
//


#import "WavePlayer.h"


/*
*  TODO: abstract this to allow for all types of waveform players (Sine, Pulse, Triangle, Saw)
*    as well as allowing for several different types of modulation waveform.
*/

@interface SinePlayer : WavePlayer {
  //Frequency information
  BOOL   modulationIsLogarithmic;

  }
@end
