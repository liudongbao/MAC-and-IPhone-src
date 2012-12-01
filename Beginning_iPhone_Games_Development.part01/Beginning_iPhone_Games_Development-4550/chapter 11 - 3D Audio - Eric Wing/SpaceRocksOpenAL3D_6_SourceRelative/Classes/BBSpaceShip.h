//
//  BBSpaceShip.h
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@class BBParticleSystem;
@class EWSoundListenerObject;

@interface BBSpaceShip : BBMobileObject {
	BOOL dead;
	BBParticleSystem * particleEmitter;
	BBRange xVeloRange;
	BBRange yVeloRange;
	NSMutableArray * secondaryColliders;
	BOOL isThrusting;
	BOOL explosionDidEnd;
	NSUInteger explosionID;
	EWSoundListenerObject* soundListenerObject;
}

- (void) dealloc;
- (void)awake;
- (void)deadUpdate;
- (void)didCollideWith:(BBSceneObject*)sceneObject; ;
- (void)fireMissile;
- (void)handleCollision;
- (void)update;

// 7 methods


@end
