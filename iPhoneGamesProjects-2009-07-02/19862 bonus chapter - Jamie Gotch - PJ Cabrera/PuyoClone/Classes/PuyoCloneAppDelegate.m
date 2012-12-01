//
//  PuyoCloneAppDelegate.m
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "PuyoCloneAppDelegate.h"
#include "GameScene.h"

@implementation PuyoCloneAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// Init the window
	window = 
		[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	//[window setMultipleTouchEnabled:YES];

	// Init Cocos2D Director
	//[Director useFastDirector];
	//[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDisplayFPS:YES];

	// Attach Cocos2D Director to the window and make it visible.
	[[Director sharedDirector] attachInWindow:window];
	[window makeKeyAndVisible];
	
	// Seed random number generator.
	struct timeval tv;
	gettimeofday( &tv, 0 );
	srandom( tv.tv_usec + tv.tv_sec );

	// Start the game by running the GameScene.
	[[Director sharedDirector] runWithScene: [GameScene node]];
}

-(void)dealloc
{
	[window release];
	[super dealloc];
}

// This method gets called when the game is interrupted by a phone call.
// We're going to pause the game and pop up an alert view to allow the 
// user to resume the game once they return from their phone call.
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];

	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Resuming Game" 
						  message:@"Click OK to resume the game" 
						  delegate:self 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

// This method gets called when the user closes the alert view.
// Here is where we resume the paused game.
- (void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	[[Director sharedDirector] resume];
}

// This method gets called when the user returns to the game from a 
// phone call. We won't do anything here, we will resume when the 
// alert view is closed.
-(void) applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

@end
