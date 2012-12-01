//
//  BBMissile.h
//  SpaceRocks
//
//  Created by ben smith on 5/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@class BBParticleSystem;


@interface BBMissile : BBMobileObject {
	BBParticleSystem * particleEmitter;
	BOOL destroyed;
	BBPoint emitterOffset;
}

- (void) dealloc;
- (void)awake;
- (void)checkArenaBounds;
- (void)didCollideWith:(BBSceneObject*)sceneObject; ;
- (void)handleCollision;
- (void)update;

// 6 methods

@end
