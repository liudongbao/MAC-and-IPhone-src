//
//  BasicOpenALStreamingAppDelegate.m
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import "BasicOpenALStreamingAppDelegate.h"
#import "BasicOpenALStreamingViewController.h"

@implementation BasicOpenALStreamingAppDelegate

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
