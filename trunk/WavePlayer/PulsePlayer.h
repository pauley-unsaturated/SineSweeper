//
//  PulsePlayer.h
//  SineSweeper
//
//  Created by Mark Pauley on 6/3/07.
//  Copyright 2007 Unsaturated Studios. All rights reserved.
//

#import "WavePlayer.h"

@interface PulsePlayer : WavePlayer {
	double dutyCycle;
	double previousPositiveSquare;
	double previousNegativeSquare;
}

@end
