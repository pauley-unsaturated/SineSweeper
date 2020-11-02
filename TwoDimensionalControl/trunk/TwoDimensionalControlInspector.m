//
//  TwoDimensionalControlInspector.m
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "TwoDimensionalControlInspector.h"
#import "TwoDimensionalControl.h"

@implementation TwoDimensionalControlInspector

- (id)init
{
    self = [super init];
    [NSBundle loadNibNamed:@"TwoDimensionalControlInspector" owner:self];
    return self;
}

- (void)ok:(id)sender
{
  TwoDimensionalControl* selectedControl = [self object];
  NSPoint minPoint;
  NSSize  dimensions;
  
  minPoint.x = [minXField floatValue];
  minPoint.y = [minYField floatValue];
  dimensions.width = [widthField floatValue];
  dimensions.height = [heightField floatValue];
  
  [selectedControl setMinValue:minPoint];
  [selectedControl setDimensions:dimensions];
  [super ok:sender];
}

- (void)revert:(id)sender
{
	/* Your code Here */
    [super revert:sender];
}

@end
