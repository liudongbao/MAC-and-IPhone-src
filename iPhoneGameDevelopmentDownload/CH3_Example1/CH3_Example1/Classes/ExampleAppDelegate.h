//
//  ExampleAppDelegate.h
//  Example
//
//  Created by Paul Zirkle on 4/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "GameStateManager.h"
#include "gsMain.h"

@class ExampleViewController;

@interface ExampleAppDelegate : GameStateManager <UIApplicationDelegate> {
    UIWindow *window;
    ExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ExampleViewController *viewController;

@end

