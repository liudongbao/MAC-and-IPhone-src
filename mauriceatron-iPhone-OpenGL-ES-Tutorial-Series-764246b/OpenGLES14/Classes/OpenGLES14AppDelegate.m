//
//  OpenGLES14AppDelegate.m
//  OpenGLES14
//
//  Created by Simon Maurice on 7/06/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import "OpenGLES14AppDelegate.h"
#import "EAGLView.h"

@implementation OpenGLES14AppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	glView.animationInterval = 1.0 / 60.0;
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end
