//
//  OpenGLES13AppDelegate.m
//  OpenGLES13
//
//  Created by Simon Maurice on 22/05/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//

#import "OpenGLES13AppDelegate.h"
#import "EAGLView.h"

#import "LevelMap.h"
#import "ColladaModel.h"

@implementation OpenGLES13AppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	//LevelMap *map = [[LevelMap alloc] initWithMapFileName:@"gothic"];
	//[map release];
	
	ColladaModel *model = [[ColladaModel alloc] initWithFilename:@"pob"];
	[model release];
	
	glView.animationInterval = 1.0 / 60.0;
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end
