//
//  TilemapAppDelegate.h
//  Tilemap
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface TilemapAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
