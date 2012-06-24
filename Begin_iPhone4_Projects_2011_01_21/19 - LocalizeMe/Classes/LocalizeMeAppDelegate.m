//
//  LocalizeMeAppDelegate.m
//  LocalizeMe
//
//  Created by JN on 10/29/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LocalizeMeAppDelegate.h"

#import "LocalizeMeViewController.h"

@implementation LocalizeMeAppDelegate


@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
     
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}

- (void)dealloc {

    [window release];
    [viewController release];
    [super dealloc];
}

@end
