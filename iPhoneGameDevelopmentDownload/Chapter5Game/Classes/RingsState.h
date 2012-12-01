//
//  RingState.h
//  Chapter 5 Game
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLESGameState3D.h"
#import "Sprite3D.h"
#import "Camera.h"
#import "Particle.h"
#import "Ring.h"

#define RING_COUNT 11
#define MAX_PARTICLES 100

//maximum number of time entries we want to save
#define MAX_TIMES 10


@interface RingsState : GLESGameState3D <UIAccelerometerDelegate> {
	UIAccelerationValue		accel[3];
	Sprite3D *ship;
	Ring *rings[RING_COUNT];
	Particle *particle[MAX_PARTICLES];
	Model *engine_particle, *ring_particle;
	Camera *camera;
	Sprite3D *skybox;
	
	float speed_knob;

	bool invertX, invertY;
	PVRTVec3 calibrate_axis_right; //right
	PVRTVec3 calibrate_axis_up;
	
	double startTime, endTime; //used to track how long it takes the player to finish the circuit.
	int newbest; //stores the rank of the new high score, or -1 if no high score has been made.
}	

#define WINNING 1
#define LOSING 2

- (void) onWin;
//- (void) onFail; //not used for ringsstate, failure is not an option.
- (void) renderEndgame;
- (void) updateEndgame:(float)time;
- (void) touchEndgame;

+ (NSArray*) bestTimes;
+ (int) insertBestTime:(double) time;
+ (void) defaultBestTimes; //made public so we can nuke scores from orbit or high scores screen

@end
