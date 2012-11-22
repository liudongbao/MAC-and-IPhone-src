//
//  Hello_TriangleAppDelegate.m
//  Hello_Triangle
//
//  Created by Dan Ginsburg on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Hello_TriangleAppDelegate.h"


@implementation Hello_TriangleAppDelegate

@synthesize window=_window;
@synthesize glView=_glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	_glView.animationInterval = 1.0 / 60.0;
	[_glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	_glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	_glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[_window release];
	[_glView release];
	[super dealloc];
}

@end
