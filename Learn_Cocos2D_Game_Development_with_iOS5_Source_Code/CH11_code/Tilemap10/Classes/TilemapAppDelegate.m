//
//  TilemapAppDelegate.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TilemapAppDelegate.h"
#import "cocos2d.h"
#import "TileMapScene.h"

@implementation TilemapAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	//CC_DIRECTOR_INIT();
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if ([CCDirector setDirectorType:kCCDirectorTypeDisplayLink] == NO)
		[CCDirector setDirectorType:kCCDirectorTypeNSTimer];
	
	CCDirector *director = [CCDirector sharedDirector];										
	[director setAnimationInterval:1.0/60];													
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:GL_DEPTH_COMPONENT24_OES];
	[director setOpenGLView:glView];
	[window addSubview:glView];																
	[window makeKeyAndVisible];																	
	
	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	[director setProjection:kCCDirectorProjection2D];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:NO];
	
	// Turn on multiple touches
	EAGLView *view = [director openGLView];
	[view setMultipleTouchEnabled:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
		
	[[CCDirector sharedDirector] runWithScene: [TileMapLayer scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CC_DIRECTOR_END();
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
