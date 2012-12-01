//
//  SystemSoundServicesAppDelegate.m
//  SystemSoundServices
//
//  Created by Eric Wing on 7/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SystemSoundServicesAppDelegate.h"
#import "SystemSoundServicesViewController.h"

@implementation SystemSoundServicesAppDelegate

@synthesize mainWindow;
@synthesize viewController;


- (void) applicationDidFinishLaunching:(UIApplication*)the_application
{    
	[mainWindow addSubview:viewController.view];
	[mainWindow makeKeyAndVisible];
}


- (void) dealloc
{
	[viewController release];
	[mainWindow release];
	[super dealloc];
}


@end
