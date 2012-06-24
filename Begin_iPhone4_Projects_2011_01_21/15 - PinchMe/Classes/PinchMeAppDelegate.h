//
//  PinchMeAppDelegate.h
//  PinchMe
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PinchMeViewController;

@interface PinchMeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PinchMeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PinchMeViewController *viewController;

@end

