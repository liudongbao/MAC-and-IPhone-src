//
//  BBCollisionController.h
//  SpaceRocks
//
//  Created by ben smith on 5/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "BBSceneObject.h"

@interface BBCollisionController : BBSceneObject {
	NSArray * sceneObjects;
	NSMutableArray * allColliders;
	NSMutableArray * collidersToCheck;
}

@property (retain) NSArray * sceneObjects;

- (void)awake;
- (void)handleCollisions;
- (void)render;
- (void)update;

// 4 methods

@end
