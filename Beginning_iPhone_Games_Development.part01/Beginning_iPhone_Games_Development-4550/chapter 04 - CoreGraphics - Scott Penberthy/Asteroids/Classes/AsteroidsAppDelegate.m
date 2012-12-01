//
//  AsteroidsAppDelegate.m
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AsteroidsAppDelegate.h"
#import "AsteroidsViewController.h"

@implementation AsteroidsAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	[application setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
	[application setStatusBarHidden:YES animated:NO];
	
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
