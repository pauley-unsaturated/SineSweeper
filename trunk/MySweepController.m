#import "MySweepController.h"
#include <math.h>

enum {
	kSineChoice = 0,
	kSawChoice,
	kTriangleChoice,
	kPulseChoice
};

@implementation MySweepController

-(id)init
{
  if(nil == (self = [super init]))
	return nil;
  
  player = [[SinePlayer alloc] init];
  
  return self;
}

-(void)awakeFromNib
{
	startFreq = 440;
	endFreq = 880;
	sweepRate = 1.0;
	updateInterval = 1;
	[self updatePlayer];
	[self updateDisplay];
}

- (IBAction)sweepRateChange:(NSControl*)sender
{
  sweepRate = [self expInterpValue:[sender doubleValue]
							 outOf:2
							  from:0.001
								to:2];
  [self updatePlayer];
  [self updateDisplay];
}

- (IBAction)startingFrequencyChange:(NSControl*)sender;
{
  startFreq = [sender doubleValue];
  [self updatePlayer];
  [self updateDisplay];
}

-(IBAction)endingFreqChange:(NSControl*)sender
{
  endFreq = [sender doubleValue];
  [self updatePlayer];
  [self updateDisplay];
}

-(IBAction)frequencyControllerChange:(TwoDimensionalControl*)sender
{
  NSPoint curValue = [sender getValue];
  NSSize  maxValue = [sender dimensions];
  startFreq = [self expInterpValue:curValue.y
							 outOf:maxValue.height
							  from:20.0
								to:20000.0];
  endFreq = [self expInterpValue:curValue.x
						   outOf:maxValue.width
							from:20.0
							  to:20000.0];
  
  [self updatePlayer];
  [self updateDisplay];
 }

- (IBAction)updateIntervalChange:(NSControl *)sender
{
	updateInterval = (int)[self expInterpValue: [sender intValue]
									     outOf: 88000.0
									      from: 1.0
									        to: 88000.0];
	[self updatePlayer];
	[self updateDisplay];
}


- (IBAction)resetSweep: (NSButton*)sender
{
  
}


- (IBAction)toggleSweep:(NSButton*)sender
{
  if([sweepButton state] == NSOnState)
	[player startPlaying];
  else
	[player stopPlaying];
}

- (IBAction)changeWaveform: (NSMatrix*)sender {
	int waveformChoice = [sender selectedRow];
	[player stopPlaying];
	[player release];
	player = NULL;
	switch(waveformChoice) {
		case kSineChoice:
			player = [[SinePlayer alloc] init];
			break;
		case kSawChoice:
			player = [[SawPlayer alloc] init];
			break;
		case kTriangleChoice:
			//player = [[TrianglePlayer alloc] init];
			break;
		case kPulseChoice:
			player = [[PulsePlayer alloc] init];
			break;
	}
	//[waveformSelectionMatrix setNeedsDisplay:YES];
	if(player) {
		[self updatePlayer];
		if([sweepButton state] == NSOnState)
			[player startPlaying];
	}
	else {
		[sweepButton setState:NSOffState];
		[sweepButton setNeedsDisplay:YES];
	}
}

- (IBAction)toggleAnalog: (NSButton*)sender {
	[self updatePlayer];
	[self updateDisplay];
}


-(void)updatePlayer
{
  if(player) {
	[player setSweepRate: sweepRate];
	[player setStartFreq: startFreq];
	[player setEndFreq: endFreq];
	[player setFreqUpdateInterval: updateInterval];
	[player setIsAnalog: [analogToggle state]?YES:NO];
  }
}

-(void)updateDisplay
{
  [sweepRateDisplay setDoubleValue:sweepRate];
  [sweepRateDisplay setNeedsDisplay:YES];
  
  [endingFrequencyDisplay setDoubleValue:endFreq];
  [endingFrequencyDisplay setNeedsDisplay:YES];
  
  [startingFrequencyDisplay setDoubleValue:startFreq];
  [startingFrequencyDisplay setNeedsDisplay:YES];
  
  [updateIntervalDisplay setIntValue:updateInterval];
  [updateIntervalDisplay setNeedsDisplay:YES];
}


- (double)expInterpValue:(double)x
				   outOf:(double)maxX
					from:(double)minY 
					  to:(double)maxY
{
  return minY * exp( (log(maxY/minY) / maxX) * x);
}

-(double)expUnInterpValue:(double)y
					outOf:(double)maxX
					 from:(double)minY
					   to:(double)maxY
{
  return maxX * (log(y / minY) / log(maxY / minY));
}

@end
