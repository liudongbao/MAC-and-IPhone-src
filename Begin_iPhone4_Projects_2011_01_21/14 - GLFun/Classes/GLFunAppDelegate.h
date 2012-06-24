//
//  GLFunAppDelegate.h
//  GLFun
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLFunViewController;

@interface GLFunAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GLFunViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GLFunViewController *viewController;

@end

