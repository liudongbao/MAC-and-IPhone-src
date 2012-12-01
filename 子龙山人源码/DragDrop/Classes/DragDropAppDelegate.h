//
//  DragDropAppDelegate.h
//  DragDrop
//
//  Created by Ray Wenderlich on 11/15/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface DragDropAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
