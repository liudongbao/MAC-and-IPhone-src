//
//  Chapter3_FrameworkAppDelegate.h
//  Chapter 5 Game
//
//  Created by Paul Zirkle on 4/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ResourceManager.h"
#include "GameStateManager.h"

@class Game3dViewController;

#define ProgressionSavefile @"progression"

@interface Game3dAppDelegate : GameStateManager <UIApplicationDelegate> {
    UIWindow *window;
    Game3dViewController *viewController;
	
	CFTimeInterval m_FPS_lastSecondStart;
	int m_FPS_framesThisSecond;
	
	CFTimeInterval m_lastUpdateTime;
	float m_estFramesPerSecond;	
}

- (void) gameLoop: (id) sender;

- (float) getFramesPerSecond;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Game3dViewController *viewController;

@end

