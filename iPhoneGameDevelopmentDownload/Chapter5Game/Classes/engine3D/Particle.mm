//
//  Particle.m
//  Chapter5
//
//  Created by Joe Hogue on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"


@implementation Particle

+ (id) particleWithModel:(Model*)model {
	Particle *retval = [[Particle alloc] init];
	retval.model = model;
	return [retval autorelease];
}

- (id) init {
	[super init];
	[self resetLife:0.0f velocitiy:PVRTVec3(0, 0, 0) framespeed:0];
	self.scale = 0.025f;
	return self;
}

- (void) resetLife:(float)life velocitiy:(PVRTVec3)vel framespeed:(float)framespeed {
	frame = 0;
	_life = life;
	_vel = vel;
	_framespeed = framespeed;
}

- (void) update:(float)time {
	if(!_life) return;
	_life -= time;
	if(_life <= 0.0f){
		_life = 0.0f;
		return;
	}
	
	frame += _framespeed*time;
	if(frame > model.numFrames){
		frame -= model.numFrames;
	}
	
	translate += _vel * time;
}

- (bool) alive {
	return _life != 0.0f;
}

- (void) draw {
	if ([self alive])
		[super draw];
}

@end
