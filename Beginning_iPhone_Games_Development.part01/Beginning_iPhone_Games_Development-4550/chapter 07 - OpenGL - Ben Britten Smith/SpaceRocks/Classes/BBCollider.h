//
//  BBCollider.h
//  SpaceRocks
//
//  Created by ben smith on 7/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneObject.h"

@protocol BBCollisionHandlerProtocol
- (void)didCollideWith:(BBSceneObject*)sceneObject; 
@end

@interface BBCollider : BBSceneObject {
	BBPoint transformedCentroid;
	BOOL checkForCollision;
	CGFloat maxRadius;
}

@property (assign) BOOL checkForCollision;
@property (assign) CGFloat maxRadius;

+ (BBCollider*)collider;
- (BOOL)doesCollideWithCollider:(BBCollider*)aCollider;
- (BOOL)doesCollideWithMesh:(BBSceneObject*)sceneObject;
- (void)dealloc;
- (void)awake;
- (void)render;
- (void)updateCollider:(BBSceneObject*)sceneObject;

// 6 methods


@end
