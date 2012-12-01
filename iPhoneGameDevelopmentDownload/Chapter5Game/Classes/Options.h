//
//  Options.h
//  Chapter5
//
//  Created by Joe Hogue on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameState.h"

@interface Options : GameState <UIAccelerometerDelegate> {
	UIView* subview;
	IBOutlet UISwitch *invertY, *invertX;
	IBOutlet UILabel *calibrateResult;

	UIAccelerationValue		accel[3];
}

-(IBAction) invertY;
-(IBAction) invertX;
-(IBAction) calibrate;
-(IBAction) done;
-(IBAction) defaults;
+ (void) setupDefaults;

@property (nonatomic, retain) IBOutlet UIView* subview;

@end
