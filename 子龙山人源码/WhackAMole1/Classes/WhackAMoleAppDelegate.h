//
//  WhackAMoleAppDelegate.h
//  WhackAMole
//
//  Created by Ray Wenderlich on 1/5/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface WhackAMoleAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;    
}

@property (nonatomic, retain) UIWindow *window;

@end
