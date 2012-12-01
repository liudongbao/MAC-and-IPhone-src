//
//  BBUFO.h
//  SpaceRocks3D
//
//  Created by ben smith on 31/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@class BBParticleSystem;


@interface BBUFO : BBMobileObject {
	BBParticleSystem * particleEmitter;
	NSInteger missileCountDown;
	BOOL destroyed;
}

- (void) dealloc;
- (void)awake;
- (void)checkArenaBounds;
- (void)didCollideWith:(BBSceneObject*)sceneObject; ;
- (void)fireMissile;
- (void)handleCollision;
- (void)update;

// 7 methods


@end
