//
//  TwoDimensionalControl.h
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TwoDimensionalControl : NSControl
{
  NSPoint    value;
  NSPoint    minValue;
  NSSize     dimensions;
  NSColor*   foregroundColor;
  NSColor*   backgroundColor;
  SEL        action;
  id         target;
}


/*value binding method (should just get the value member)*/
-(const NSPoint)getValue;
-(void)setValue:(NSPoint) newValue;
-(void)resetValue;

/*xValueBinding methods*/
-(float)getXValue;
-(void)setXValue:(float) xValue;
-(IBAction)takeXValueFrom:(id) sender;

/*yValueBinding methods*/
-(float)getYValue;
-(void)setYValue:(float) yValue;
-(IBAction)takeYValueFrom:(id) sender;

-(void)setMinValue:(NSPoint)  newMinValue;
-(const NSPoint)minValue;
-(void)setDimensions:(NSSize) newDimensions;
-(const NSSize)dimensions;

-(void)setForegroundColor:(NSColor*)newForegroundColor;
-(void)setBackgroundColor:(NSColor*)newBackgroundColor;

-(void)displayValue;
-(void)drawValueAxes;

@end
