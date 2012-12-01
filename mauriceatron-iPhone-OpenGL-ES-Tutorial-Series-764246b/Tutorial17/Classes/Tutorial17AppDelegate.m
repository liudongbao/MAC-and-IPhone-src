//
//  Tutorial17AppDelegate.m
//  Tutorial17
//
//  Created by Simon Maurice on 25/07/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import "Tutorial17AppDelegate.h"
#import "EAGLView.h"

@implementation Tutorial17AppDelegate

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
