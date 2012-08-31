//
//  PhysicsBox2dAppDelegate.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//
#import <UIKit/UIKit.h>

@interface PhysicsBox2dAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;

@end
