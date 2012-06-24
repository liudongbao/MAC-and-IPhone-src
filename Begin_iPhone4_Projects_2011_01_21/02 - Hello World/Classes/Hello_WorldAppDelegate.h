//
//  Hello_WorldAppDelegate.h
//  Hello World
//
//  Created by Dave Mark on 8/22/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@class Hello_WorldViewController;

@interface Hello_WorldAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;

    Hello_WorldViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet Hello_WorldViewController *viewController;

@end

