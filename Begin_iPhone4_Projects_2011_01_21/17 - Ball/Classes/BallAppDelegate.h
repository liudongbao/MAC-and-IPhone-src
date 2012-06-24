//
//  BallAppDelegate.h
//  Ball
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BallViewController;

@interface BallAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BallViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BallViewController *viewController;

@end

