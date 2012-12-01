//
//  OpenGLES12AppDelegate.m
//  OpenGLES12
//
//  Created by Simon Maurice on 28/04/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import "OpenGLES12AppDelegate.h"
#import "EAGLView.h"

@implementation OpenGLES12AppDelegate

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
