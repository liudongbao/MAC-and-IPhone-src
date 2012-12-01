//
//  BBCollisionController.m
//  SpaceRocks
//
//  Created by ben smith on 5/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBCollisionController.h"
#import "BBMobileObject.h"
#import "BBCollider.h"


@implementation BBCollisionController

@synthesize sceneObjects;

-(void)handleCollisions
{
	// two types of colliders
	// ones that need to be checked for collision and ones that do not
	if (allColliders == nil) allColliders = [[NSMutableArray alloc] init];
	[allColliders removeAllObjects];
	if (collidersToCheck == nil) collidersToCheck = [[NSMutableArray alloc] init];
	[collidersToCheck removeAllObjects];
	
	for (BBSceneObject * obj in sceneObjects) {
		if (obj.collider != nil){
			[allColliders addObject:obj];
			if (obj.collider.checkForCollision) [collidersToCheck addObject:obj];
		}	
	}

	// now check to see if anythign is hitting anything else
	for (BBSceneObject * colliderObject in collidersToCheck) {
		for (BBSceneObject * collideeObject in allColliders) {
			if (colliderObject == collideeObject) continue;
			if ([colliderObject.collider doesCollideWithCollider:collideeObject.collider]) {
				if ([colliderObject respondsToSelector:@selector(didCollideWith:)]) [(id<BBCollisionHandlerProtocol>)colliderObject didCollideWith:collideeObject];
			}
		}
	}
}

#pragma mark BBSceneObject overrides for rendering and debug

-(void)awake
{
}

// called once every frame
-(void)update
{	
}

// called once every frame
-(void)render
{
	if (!active) return; // if we do not have a mesh, no need to render
	// clear the matrix
	glPushMatrix();
	glLoadIdentity();
	for (BBSceneObject * obj in allColliders) {						
		[obj.collider render];
	}
	glPopMatrix();
}



@end
