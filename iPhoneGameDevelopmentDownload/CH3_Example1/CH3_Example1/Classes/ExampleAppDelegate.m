//
//  ExampleAppDelegate.m
//  Example
//
//  Created by Paul Zirkle on 4/15/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ExampleAppDelegate.h"
#import "ExampleViewController.h"

#define IPHONE_HEIGHT 480
#define IPHONE_WIDTH 320

@implementation ExampleAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
    //[window makeKeyAndVisible];
	
	[self doStateChange: [gsMain class]];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

- (void) doStateChange: (Class) state
{
	
	if( viewController.view != nil ) {
		[viewController.view removeFromSuperview]; //remove view from window's subviews.
		[viewController.view release]; //release gamestate 
	}
	
	viewController.view = [[state alloc]  initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT) andManager:self];
	
	//now set our view as visible
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];	
	
}

@end
