//
//  SoundTest.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsSoundTest : GameState {
	IBOutlet UIView* subview;
}

-(IBAction) playCafSfx;
-(IBAction) playMp3;

-(IBAction) stopMusic;


-(IBAction) back;
@end
