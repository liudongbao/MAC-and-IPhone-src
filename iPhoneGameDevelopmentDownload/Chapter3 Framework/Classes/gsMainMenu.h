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
}

- (IBAction) doTextureTest;
- (IBAction) doStorageTest;
- (IBAction) doSoundTest;
- (IBAction) doTextureTest;

@end
