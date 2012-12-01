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
	CGFloat * collisionVertexes;
}

@property (assign) BOOL checkForCollision;
@property (assign) CGFloat maxRadius;
@property (assign) CGFloat * collisionVertexes;

+ (BBCollider*)collider;
- (BOOL)doesCollideWithCollider:(BBCollider*)aCollider;
- (BOOL)doesCollideWithMesh:(BBSceneObject*)sceneObject;
- (void)dealloc;
- (void)awake;
- (void)render;
- (void)updateCollider:(BBSceneObject*)sceneObject;

-(BOOL)doesCollideWithVertexes:(CGFloat*)vertexes 
												 count:(NSInteger)vertexCount
												size:(NSInteger)size
												matrix:(CGFloat*)matrix;

// 6 methods


@end
