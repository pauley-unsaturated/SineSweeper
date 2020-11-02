//
//  TwoDimensionalControlPalette.h
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>
#import "TwoDimensionalControl.h"

@interface TwoDimensionalControlPalette : IBPalette
{
  IBOutlet TwoDimensionalControl* control;
}
@end

@interface TwoDimensionalControl (TwoDimensionalControlPaletteInspector)
- (NSString *)inspectorClassName;
@end
