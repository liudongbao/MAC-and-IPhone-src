//
//  Simple_TableAppDelegate.h
//  Simple Table
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Simple_TableViewController;

@interface Simple_TableAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    Simple_TableViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Simple_TableViewController *viewController;

@end

