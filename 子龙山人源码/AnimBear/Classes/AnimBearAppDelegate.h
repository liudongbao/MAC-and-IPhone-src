//
//  AnimBearAppDelegate.h
//  AnimBear
//
//  Created by Ray Wenderlich on 11/8/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AnimBearAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
