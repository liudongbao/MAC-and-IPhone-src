//
//  EssentialsAppDelegate.m
//  Essentials
//
//  Created by Steffen Itterheim on 14.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "EssentialsAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation EssentialsAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// this is the necessary Cocoa Touch part
	// a cocoa touch window is created and setup, later cocos2d's OpenGL is attached to this window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Uncomment the next line to seed the randomizer with the current time.
	// Otherwise the CCRANDOM methods return the same sequence of numbers each time the App is started.
	// Try running the App a few times with and without the call to srandom and see how the colors change.
	/*
	srandom(time(NULL));
	 */

	// cocos2d is now fully initialized and it's time to run our first scene (the familiar HelloWorldScene)
	// NOTE: the runWithScene method is only ever used here
	// if you want to change scenes later you'll have to use the replaceScene method instead
	[[CCDirector sharedDirector] runWithScene:[HelloWorld scene]];
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
