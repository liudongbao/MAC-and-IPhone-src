//
//  AppDelegate.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
