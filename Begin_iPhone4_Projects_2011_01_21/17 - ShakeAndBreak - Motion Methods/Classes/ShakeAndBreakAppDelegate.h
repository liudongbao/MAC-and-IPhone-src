//
//  ShakeAndBreakAppDelegate.h
//  ShakeAndBreak
//
//  Created by JN on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

