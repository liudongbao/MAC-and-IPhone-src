//
//  Chapter3_FrameworkAppDelegate.h
//  Chapter3 Framework
//
//  Created by Paul Zirkle on 4/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ResourceManager.h"
#include "GameStateManager.h"

@class Game2dViewController;

#define ProgressionSavefile @"progression"

@interface Game2dAppDelegate : GameStateManager <UIApplicationDelegate> {
    UIWindow *window;
    Game2dViewController *viewController;
	
	CFTimeInterval m_FPS_lastSecondStart;
	int m_FPS_framesThisSecond;
	
	CFTimeInterval m_lastUpdateTime;
	float m_estFramesPerSecond;	
}

- (void) gameLoop: (id) sender;

- (float) getFramesPerSecond;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Game2dViewController *viewController;

@end

