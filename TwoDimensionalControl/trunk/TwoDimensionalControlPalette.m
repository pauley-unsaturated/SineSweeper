//
//  TwoDimensionalControlPalette.m
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "TwoDimensionalControlPalette.h"

static const NSSize  kDefaultDimensions = {200, 200};
static const NSPoint kDefaultMinValue = {0, 0};

@implementation TwoDimensionalControlPalette

- (void)finishInstantiate
{
  
  [control setMinValue: kDefaultMinValue];
  [control setDimensions: kDefaultDimensions];
  [control resetValue];
  [super finishInstantiate];
  
}

@end

@implementation TwoDimensionalControl (TwoDimensionalControlPaletteInspector)

- (NSString *)inspectorClassName
{
    return @"TwoDimensionalControlInspector";
}

@end
