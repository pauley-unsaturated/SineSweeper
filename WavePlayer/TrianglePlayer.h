//
//  TrianglePlayer.h
//  SineSweeper
//
//  Created by Mark Pauley on 6/19/07.
//  Copyright 2007 Unsaturated Studios. All rights reserved.
//

#import "WavePlayer.h"


@interface TrianglePlayer : WavePlayer {
  double previousSquare;
  int curPolarity;
}

@end
