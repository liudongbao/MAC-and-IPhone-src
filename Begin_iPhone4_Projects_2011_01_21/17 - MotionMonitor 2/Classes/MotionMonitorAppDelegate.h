//
//  MotionMonitorAppDelegate.h
//  MotionMonitor
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MotionMonitorViewController;

@interface MotionMonitorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MotionMonitorViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MotionMonitorViewController *viewController;

@end

