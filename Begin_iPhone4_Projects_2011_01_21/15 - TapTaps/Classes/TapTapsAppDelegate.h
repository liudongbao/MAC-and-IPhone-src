//
//  TapTapsAppDelegate.h
//  TapTaps
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TapTapsViewController;

@interface TapTapsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TapTapsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TapTapsViewController *viewController;

@end

