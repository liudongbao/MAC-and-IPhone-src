//
//  UITest.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsMainMenu : GameState {
	IBOutlet UIView* subview;
	UIButton *lvl1, *lvl2, *lvl3, *lvl4;
}

@property (nonatomic, retain) IBOutlet UIButton *lvl1, *lvl2, *lvl3, *lvl4;

- (IBAction) doEmuLevel;
- (IBAction) doAboutScreen;
- (IBAction) doSoundTest;
- (IBAction) doEmuLevel;
- (IBAction) doLionLevel;
- (IBAction) doMazeLevel;
- (IBAction) doRiverLevel;

@end
