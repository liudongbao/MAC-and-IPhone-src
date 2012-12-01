//
//  Ring.mm
//  Chapter5
//
//  Created by Joe Hogue on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ring.h"

@implementation Ring

@synthesize normal, active;

- (void) forwardX:(float)x Y:(float)y Z:(float)z {
	PVRTVec3 up(x, y, z);
	up.normalize();
	normal = up;
	[super forwardX:x Y:y Z:z];
}

+ (id) ringWithModel:(Model*)model {
	Ring *retval = [[Ring alloc] init];
	retval.model = model;
	return [retval autorelease];
}

- (id) init {
	[super init];
	active = true;
	lastDistance = 1;
	return self;
}

- (bool) update:(float)time collideWith:(Sprite3D*) ship {
	//if(!active) return;
	bool retval = false;
	float dist = (translate-ship.position).dot(normal);
	int newdist = dist > 0.0f? 1 : -1;
	//collision detection concept from http://www.gamespp.com/algorithms/collisionDetectionTutorial01.html
	if(newdist != lastDistance){
		//ship crossed our plane; see if it was within the ring when it did so.
		lastDistance = newdist;
		PVRTVec3 toward = translate-ship.position;
		float distsquared = toward.x*toward.x+toward.y*toward.y+toward.z*toward.z;
		if(distsquared < 50*50){ //torus major radius is 60, minor radius is 10.
			//detected a proper fly-through.
			active = false;
			retval = true;
			NSLog(@"detected fly through.");
		}
	}
	//NSLog(@"dist %f", dist);
	//[super update:time];
	
	if(!active){
		if(frame < model.numFrames-1)
			frame += 30*time;
		if(frame > model.numFrames-1)
			frame = model.numFrames-1;
	}
	
	return retval;
}

@end
