//
//  AppleCoder_OpenGLES_00AppDelegate.m
//  AppleCoder-OpenGLES-00
//
//  Created by Simon Maurice on 18/03/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import "AppleCoder_OpenGLES_00AppDelegate.h"
#import "EAGLView.h"

@implementation AppleCoder_OpenGLES_00AppDelegate

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
