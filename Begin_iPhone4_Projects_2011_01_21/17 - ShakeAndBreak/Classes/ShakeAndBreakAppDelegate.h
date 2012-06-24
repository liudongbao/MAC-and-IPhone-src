//
//  ShakeAndBreakAppDelegate.h
//  ShakeAndBreak
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShakeAndBreakViewController;

@interface ShakeAndBreakAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ShakeAndBreakViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ShakeAndBreakViewController *viewController;

@end

