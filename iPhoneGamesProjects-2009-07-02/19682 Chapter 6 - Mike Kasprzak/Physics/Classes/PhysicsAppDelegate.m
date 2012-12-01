//
//  PhysicsAppDelegate.m
//  Physics
//
//  Created by Michael Kasprzak on 16/02/09.
//  Copyright Sykhronics Entertainment 2009. All rights reserved.
//

#import "PhysicsAppDelegate.h"
#import "EAGLView.h"

#define kAccelerometerFrequency     40


@implementation PhysicsAppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Configure and start the accelerometer
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	glView.animationInterval = 1.0 / 60.0;
	[glView startAnimation];
}

extern float AccelerometerX;
extern float AccelerometerY;
extern float AccelerometerZ;

float AccelerometerX;
float AccelerometerY;
float AccelerometerZ;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	AccelerometerX = acceleration.x;
	AccelerometerY = acceleration.y;
	AccelerometerZ = acceleration.z;
    
	// Update the accelerometer graph view
//    [graphView updateHistoryWithX:acceleration.x Y:acceleration.y Z:acceleration.z];
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
