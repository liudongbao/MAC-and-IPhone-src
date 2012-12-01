//
//  CoreAChickenAppDelegate.m
//  CoreAChicken
//
//  Created by PJ Cabrera on 10/3/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "CoreAChickenAppDelegate.h"
#import "CoreAChickenViewController.h"

@implementation CoreAChickenAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
