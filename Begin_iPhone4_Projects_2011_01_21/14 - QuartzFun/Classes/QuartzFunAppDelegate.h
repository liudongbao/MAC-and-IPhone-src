//
//  QuartzFunAppDelegate.h
//  QuartzFun
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuartzFunViewController;

@interface QuartzFunAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    QuartzFunViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet QuartzFunViewController *viewController;

@end

