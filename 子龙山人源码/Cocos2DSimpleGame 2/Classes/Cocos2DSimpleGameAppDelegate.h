//
//  Cocos2DSimpleGameAppDelegate.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/21/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface Cocos2DSimpleGameAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
