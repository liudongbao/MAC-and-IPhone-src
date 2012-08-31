//
//  SpriteBatchesAppDelegate.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
//

#import "SpriteBatchesAppDelegate.h"
#import "cocos2d.h"
#import "GameScene.h"

@implementation SpriteBatchesAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    // Init the display. This code is taken from CC_DIRECTOR_INIT()
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];					
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )								
    {
		[CCDirector setDirectorType:kCCDirectorTypeNSTimer];									        
    }

    // Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
    // Now we set the background to RGBA8 for better quality
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]								
                                   pixelFormat:kEAGLColorFormatRGBA8							
                                   depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */				
                            preserveBackbuffer:NO											
                                    sharegroup:nil												
                                 multiSampling:NO												
                               numberOfSamples:0												
                        ];											
	[director setOpenGLView:glView];														
    [window addSubview:glView];																
    [window makeKeyAndVisible];																	

    // Turn on multiple touches
	[glView setMultipleTouchEnabled:YES];

    // Enables High Res mode (Retina Display) on iPhone 4 and maintains 
    // low res on all other devices
	if(![director enableRetinaDisplay:YES])
    {
    	CCLOG(@"Retina Display Not supported");
    }    
    
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];	

    // Set the animation interval: 60fps desired
    [director setAnimationInterval:1.0/60];													

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];	

    // Enable pre multiplied alpha for PVR textures to avoid
    // artifacts
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    // run the main scene
	[[CCDirector sharedDirector] runWithScene: [GameScene scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
