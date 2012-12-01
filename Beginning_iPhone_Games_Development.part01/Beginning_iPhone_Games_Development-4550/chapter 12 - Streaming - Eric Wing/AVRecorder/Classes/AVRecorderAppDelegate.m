//
//  AVRecorderAppDelegate.m
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import "AVRecorderAppDelegate.h"
#import "AVRecorderViewController.h"

@implementation AVRecorderAppDelegate

@synthesize mainWindow;
@synthesize viewController;


- (void) applicationDidFinishLaunching:(UIApplication*)the_application
{
	// Override point for customization after app launch
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
