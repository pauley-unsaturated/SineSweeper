//
//  TwoDimensionalControl.m
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "TwoDimensionalControl.h"
#include<stdlib.h>

@implementation TwoDimensionalControl

+(void)initialize
{
  [self exposeBinding:@"value"];
  [self exposeBinding:@"xValue"];
  [self exposeBinding:@"yValue"];
  [self exposeBinding:@"minValue"];
  [self exposeBinding:@"dimensions"];
  [self exposeBinding:@"foregroundColor"];
  [self exposeBinding:@"backgroundColor"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];	 
  //self = [self initWithFrame: [self frame]];
  
  /*
   * Decode the archived members
   */
  [self setValue:[decoder decodePointForKey:@"value"]];
  [self setMinValue:[decoder decodePointForKey:@"minValue"]];
  [self setDimensions:[decoder decodeSizeForKey:@"dimensions"]];
  [self setForegroundColor:[decoder decodeObjectForKey:@"foregroundColor"]];
  [self setBackgroundColor:[decoder decodeObjectForKey:@"backgroundColor"]];
 

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{

  /*
   * Encode the members
   */
  [coder encodePoint:value    forKey:@"value"];
  [coder encodePoint:minValue forKey:@"minValue"];
  [coder encodeSize:dimensions forKey:@"dimensions"];
  [coder encodeObject:foregroundColor forKey:@"foregroundColor"];
  [coder encodeObject:backgroundColor forKey:@"backgroundColor"];
  [super encodeWithCoder:coder];
}

-(id)initWithFrame:(NSRect)frame
{
  if(!(self = [super initWithFrame:frame]))
	return nil;
 
  foregroundColor = [NSColor blackColor];
  backgroundColor = [NSColor whiteColor];
  
  dimensions.height = frame.size.height;
  dimensions.width = frame.size.width;
  
  [self resetValue];
  return self;
}

-(void)setAction:(SEL)newAction
{
  NSLog(@"%p: SetAction called", self);
  action = newAction;
}

-(SEL)action
{
  return action;
}

-(void)setTarget:(id)newTarget
{
  target = newTarget;
}

-(id)target
{
  return target;
}

-(const NSPoint)getValue
{
  return (const NSPoint)value;
}

-(void)setValue:(NSPoint) newValue
{
  //memcpy(&value, &newValue, sizeof(NSPoint));
  value = newValue;
  if(value.x < minValue.x)value.x = minValue.x;
  if(value.x > (minValue.x + dimensions.width)) value.x = (minValue.x + dimensions.width);
  
  if(value.y < minValue.y)value.y = minValue.y;
  if(value.y > (minValue.y + dimensions.height)) value.y = (minValue.y + dimensions.height);
}

-(void)resetValue
{
  NSPoint resetPoint;
  
  resetPoint.x = minValue.x + (dimensions.width / 2);
  resetPoint.y = minValue.y + (dimensions.height / 2);
  [self setValue: resetPoint];
}

-(float)getXValue
{
  return value.x;
}

-(void)setXValue:(float) xValue
{
  NSPoint newValue = value;
  newValue.x = xValue;
  [self setValue:newValue];
}

-(IBAction)takeXValueFrom:(id)sender
{
  [self setXValue:[sender floatValue]];
};

-(float)getYValue
{
  return value.y;
}

-(void)setYValue:(float) yValue
{
  NSPoint newValue = value;
  newValue.y = yValue;
  [self setValue:newValue];
}

-(IBAction)takeYValueFrom:(id) sender
{
  [self setYValue:[sender floatValue]];
}

-(void)setMinValue:(NSPoint)  newMinValue
{
  minValue.x = newMinValue.x;
  minValue.y = newMinValue.y;
}

-(const NSPoint)minValue
{
  return (const NSPoint)minValue;
}

-(void)setDimensions:(NSSize) newDimensions;
{
  dimensions = newDimensions;
}

-(const NSSize)dimensions
{
  return (const NSSize)dimensions;
}

-(void)setForegroundColor:(NSColor*)newForegroundColor
{
  if(foregroundColor)
	[foregroundColor release];
  
  foregroundColor = [newForegroundColor retain];
}

-(void)setBackgroundColor:(NSColor*)newBackgroundColor
{
  if(backgroundColor)
	[backgroundColor release];
  
  backgroundColor = [newBackgroundColor retain];
}


-(void)drawRect:(NSRect)rect
{
  [backgroundColor set];
  [NSBezierPath fillRect:rect];
  
  [self displayValue];
}

-(void)displayValue
{
  [self drawValueAxes];
}

-(void)drawValueAxes
{
  NSRect rect = [self bounds];
  [foregroundColor set];
  float xProportion = rect.size.width / dimensions.width;
  float yProportion = rect.size.height / dimensions.height;
  
  NSPoint startHorizontal;
  startHorizontal.x = 0;
  startHorizontal.y = value.y * yProportion;
  NSPoint endHorizontal;
  endHorizontal.x = rect.size.width;
  endHorizontal.y = value.y * yProportion;
  [NSBezierPath strokeLineFromPoint:startHorizontal toPoint:endHorizontal];
  
  NSPoint startVertical;
  startVertical.x = value.x * xProportion;
  startVertical.y = 0;
  NSPoint endVertical;
  endVertical.x = value.x * xProportion;
  endVertical.y = rect.size.height;
  [NSBezierPath strokeLineFromPoint:startVertical toPoint:endVertical];
}

-(NSPoint)getValueOfPoint:(NSPoint)coords
{
  NSRect rect = [self bounds];
  float xProportion = rect.size.width / dimensions.width;
  float yProportion = rect.size.height / dimensions.height;
  
  NSPoint newValue;
  newValue.x = coords.x / xProportion;
  if(newValue.x < 0) newValue.x = 0;
  if(newValue.x > dimensions.width) newValue.x = dimensions.width;
  
  newValue.y = coords.y / yProportion;
  if(newValue.y < 0) newValue.y = 0;
  if(newValue.y > dimensions.height) newValue.y = dimensions.height;
  
  return newValue;
}

/*change the value, redraw*/
-(void)mouseDown:(NSEvent *)theEvent
{
  NSPoint downPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self setValue:[self getValueOfPoint:downPoint]];
  [self setNeedsDisplay:YES];
 
  [self sendAction:[self action] to:[self target]];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
  NSPoint dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  [self setValue:[self getValueOfPoint:dragPoint]];
  [self setNeedsDisplay:YES];
  [self sendAction:[self action] to:[self target]];
}

@end
