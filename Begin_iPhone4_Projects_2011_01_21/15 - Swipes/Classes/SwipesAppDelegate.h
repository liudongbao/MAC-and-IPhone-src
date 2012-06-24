//
//  SwipesAppDelegate.h
//  Swipes
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipesViewController;

@interface SwipesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SwipesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SwipesViewController *viewController;

@end

