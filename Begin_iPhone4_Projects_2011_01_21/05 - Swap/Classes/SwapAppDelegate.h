//
//  SwapAppDelegate.h
//  Swap
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwapViewController;

@interface SwapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SwapViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SwapViewController *viewController;

@end

