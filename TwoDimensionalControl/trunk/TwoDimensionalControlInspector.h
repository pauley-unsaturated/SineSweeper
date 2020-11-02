//
//  TwoDimensionalControlInspector.h
//  TwoDimensionalControl
//
//  Created by Mark Pauley on Thu Jul 22 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>

@interface TwoDimensionalControlInspector : IBInspector
{
  IBOutlet NSPopUpButton* xAxisValueFunctionPopUp;
  IBOutlet NSTextField*   minXField;
  IBOutlet NSTextField*   widthField;
  
  IBOutlet NSPopUpButton* yAxisValueFunctionPopUp;
  IBOutlet NSTextField*   minYField;
  IBOutlet NSTextField*   heightField;
}

@end
