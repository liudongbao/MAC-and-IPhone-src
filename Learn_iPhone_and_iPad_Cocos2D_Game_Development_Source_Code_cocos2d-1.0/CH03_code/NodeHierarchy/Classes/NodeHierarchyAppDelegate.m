//
//  NodeHierarchyAppDelegate.m
//  NodeHierarchy
//
//  Created by Steffen Itterheim on 12.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "NodeHierarchyAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation NodeHierarchyAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	
	// cocos2d supports four types of update methods:
	// the default is the DisplayLinkDirector which uses Apple's CADisplayLink class internally
	// but is only available on iOS 3.1 and above, hence the fallback to the default CCTimerDirector (NSTimer based)
	// the other two Directors are FastDirector, which was the preferred choice before DisplayLink became available
	// and the ThreadedFastDirector, which is the preferred choice if you want to use Cocoa Touch UIKit objects
	// alongside with cocos2d
	if ( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
	{
		// choose the NSTimer based Director
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	}
	CCDirector *director = [CCDirector sharedDirector];
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//	if( ! [director enableRetinaDisplay:YES] )
	//		CCLOG(@"Retina Display Not supported");
	
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	[window addSubview: glView];
	
	[window makeKeyAndVisible];

		
		
	[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
