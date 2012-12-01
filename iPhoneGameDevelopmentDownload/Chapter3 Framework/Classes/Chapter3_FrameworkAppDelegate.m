//
//  Chapter3_FrameworkAppDelegate.m
//  Chapter3 Framework
//
//  Created by Paul Zirkle on 4/29/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Chapter3_FrameworkAppDelegate.h"
#import "Chapter3_FrameworkViewController.h"

//include the state classes we might switch to
#import "gsMainMenu.h"

#define LOOP_TIMER_MINIMUM 0.033f
#define IPHONE_HEIGHT 480
#define IPHONE_WIDTH 320

@implementation Chapter3_FrameworkAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	//allocate global resource manager.  This is not strictly necessary, as intialize will be called before anything else when
	//resourceManager is first used, but we put it here to pre-load and setup sound stuff so that we don't get an unexpected lag later.
	[ResourceManager initialize];	
	
	
	//set up main loop
	[NSTimer scheduledTimerWithTimeInterval:LOOP_TIMER_MINIMUM target:self selector:@selector(gameLoop:) userInfo:nil repeats:NO];

	m_lastUpdateTime = [[NSDate date] timeIntervalSince1970];
	
	m_FPS_lastSecondStart = m_lastUpdateTime;
	m_FPS_framesThisSecond = 0;	
	
	//PDZ - we have removed this default code because we create the view ourselves as a GameState class
    //[window addSubview:viewController.view];
    //[window makeKeyAndVisible];
	
	//set up our first state
	[self doStateChange:[gsMainMenu class]];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"appdelegeate release.");
	[g_ResManager shutdown];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"low memory, purging caches.");
	[g_ResManager purgeSounds];
	[g_ResManager purgeTextures];
}


- (void) gameLoop: (id) sender
{
	double currTime = [[NSDate date] timeIntervalSince1970];
	//float dt = currTime - m_lastUpdateTime;  //can store this as double or float
	
	//	printf("main loop");
	
	[((GameState*)viewController.view) Update];
	[((GameState*)viewController.view) Render];
	
	m_FPS_framesThisSecond++;
	float timeThisSecond = currTime - m_FPS_lastSecondStart;
	if( timeThisSecond > 1.0f ) {
		m_estFramesPerSecond = m_FPS_framesThisSecond;
		m_FPS_framesThisSecond = 0;
		m_FPS_lastSecondStart = currTime;
	}
	
	float sleepPeriod = LOOP_TIMER_MINIMUM;	
	[NSTimer scheduledTimerWithTimeInterval:sleepPeriod target:self selector:@selector(gameLoop:) userInfo:nil repeats:NO];
	//[self performSelector: @selector(gameLoop:) withObject:self afterDelay:  sleepPeriod];
	
	m_lastUpdateTime = currTime;
}

- (float) getFramesPerSecond
{
	return m_estFramesPerSecond;
}

- (void) doStateChange: (Class) state
{
	BOOL animateTransition = true;
	
	if(animateTransition){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES]; //does nothing without this line.
	}
	
	if( viewController.view != nil ) {
		[viewController.view removeFromSuperview]; //remove view from window's subviews.
		[viewController.view release]; //release gamestate 
	}
	
	viewController.view = [[state alloc]  initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT) andManager:self];
	
	//now set our view as visible
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	if(animateTransition){
		[UIView commitAnimations];	
	}
}



@end
