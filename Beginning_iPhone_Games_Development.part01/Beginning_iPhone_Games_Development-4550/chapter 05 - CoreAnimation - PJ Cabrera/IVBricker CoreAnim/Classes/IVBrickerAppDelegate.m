//
//  IVBrickerAppDelegate.m
//  IVBricker
//
//  Created by PJ Cabrera on 9/26/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "IVBrickerAppDelegate.h"
#import "IVBrickerViewController.h"
#import "ImageCache.h"

@implementation IVBrickerAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[viewController loadGameState];
	[viewController startPlaying];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[viewController pauseGame];
	[viewController saveGameState];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	[viewController pauseGame];
	[viewController saveGameState];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[ImageCache releaseCache];
}

@end
