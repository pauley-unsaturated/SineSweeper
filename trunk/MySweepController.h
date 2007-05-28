/* MySweepController */

#import <Cocoa/Cocoa.h>
#import <SinePlayer.h>
#import <TwoDimensionalControl/TwoDimensionalControl.h>

@interface MySweepController : NSObject
{
  IBOutlet NSControl*  sweepRateController;
  IBOutlet NSTextField* sweepRateDisplay;

  IBOutlet TwoDimensionalControl* frequencyController;

  IBOutlet NSTextField*  endingFrequencyDisplay;
  IBOutlet NSTextField*  startingFrequencyDisplay;
  IBOutlet NSTextField*  updateIntervalDisplay;
  
  IBOutlet NSButton*   sweepButton;
  
  SinePlayer*          player;
  
  double sweepRate;  //in octaves
  double startFreq;  //in hz
  double endFreq; // in hz
  unsigned int updateInterval;
  
}

- (IBAction)frequencyControllerChange:(TwoDimensionalControl*)sender;
- (IBAction)startingFrequencyChange:(NSControl*)sender;
- (IBAction)endingFreqChange:(NSControl*)sender;
- (IBAction)sweepRateChange:(NSControl*)sender;
- (IBAction)updateIntervalChange:(NSControl *)sender;
- (IBAction)toggleSweep:(NSButton*)sender;
- (IBAction)resetSweep: (NSButton*)sender;
- (void)updatePlayer;
- (void)updateDisplay;

- (double)expInterpValue:(double)x
				   outOf:(double)maxX
					from:(double)minY 
					  to:(double)maxY;

-(double)expUnInterpValue:(double)y
					outOf:(double)maxX
					 from:(double)minY
					   to:(double)maxY;

@end
