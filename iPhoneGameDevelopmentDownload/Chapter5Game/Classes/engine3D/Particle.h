//
//  Particle.h
//  Chapter5
//
//  Created by Joe Hogue on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sprite3D.h"
#import "PVRTVector.h"

@interface Particle : Sprite3D{
	PVRTVec3 _vel;
	float _life; //time, in seconds, that this particle will be around for.
	float _framespeed;
}

+ (id) particleWithModel:(Model*)model;

- (void) resetLife:(float)life velocitiy:(PVRTVec3)vel framespeed:(float)framespeed;
- (void) update:(float)time;
- (bool) alive;

@end
