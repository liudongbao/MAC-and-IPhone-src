//
//  OpenALCaptureAppDelegate.m
//  OpenALCapture
//
//  Created by Eric Wing on 7/7/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import "OpenALCaptureAppDelegate.h"
#import "EAGLView.h"
#import "OpenALCaptureController.h"

@implementation OpenALCaptureAppDelegate

@synthesize window;
@synthesize glView;
//@synthesize openALCaptureController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
}


- (void) dealloc
{
	[window release];
	[glView release];
	[super dealloc];
}

@end
