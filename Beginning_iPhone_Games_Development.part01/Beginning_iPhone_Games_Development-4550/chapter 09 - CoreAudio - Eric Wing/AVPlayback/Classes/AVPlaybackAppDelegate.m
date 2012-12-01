//
//  AVPlaybackAppDelegate.m
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AVPlaybackAppDelegate.h"
#import "AVPlaybackViewController.h"

@implementation AVPlaybackAppDelegate

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
