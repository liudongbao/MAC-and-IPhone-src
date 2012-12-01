//
//  BBSpaceShip.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSpaceShip.h"
#import "BBMissile.h"
#import "BBRock.h"
#import "BBCollider.h"

#pragma mark Space Ship

static NSInteger BBSpaceShipVertexStride = 2;
static NSInteger BBSpaceShipColorStride = 4;

static NSInteger BBSpaceShipOutlineVertexesCount = 5;
static CGFloat BBSpaceShipOutlineVertexes[10] = 
{0.0, 4.0,    3.0, -4.0,
1.0, -2.0,   -1.0, -2.0,
-3.0, -4.0};

static CGFloat BBSpaceShipColorValues[20] = 
{1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 
1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0};

@implementation BBSpaceShip
// called once when the object is first created.
-(void)awake
{
	mesh = [[BBMesh alloc] initWithVertexes:BBSpaceShipOutlineVertexes 
															vertexCount:BBSpaceShipOutlineVertexesCount 
														 vertexStride:BBSpaceShipVertexStride
															renderStyle:GL_LINE_LOOP];
	mesh.colors = BBSpaceShipColorValues;
	mesh.colorStride = BBSpaceShipColorStride;
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
}

-(void)fireMissile
{
	// need to spawn a missile
	BBMissile * missile = [[BBMissile alloc] init];
	missile.scale = BBPointMake(5.0, 5.0, 1.0);
	// we need to position it at the tip of our ship
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	CGFloat speedX = -sinf(radians) * 3.0;
	CGFloat speedY = cosf(radians) * 3.0;

	missile.speed = BBPointMake(speedX, speedY, 0.0);
	
	missile.translation = BBPointMake(translation.x + missile.speed.x * 3.0, translation.y + missile.speed.y * 3.0, 0.0);
	missile.rotation = BBPointMake(0.0, 0.0, self.rotation.z);

	[[BBSceneController sharedSceneController] addObjectToScene:missile];
	[missile release];
	
	[[BBSceneController sharedSceneController].inputController setFireMissile:NO];
}

// called once every frame
-(void)update
{
	[super update];
	CGFloat rightTurn = [[BBSceneController sharedSceneController].inputController rightMagnitude];
	CGFloat leftTurn = [[BBSceneController sharedSceneController].inputController leftMagnitude];

	rotation.z += ((rightTurn * -1.0) + leftTurn) * TURN_SPEED_FACTOR;

	if ([[BBSceneController sharedSceneController].inputController fireMissile]) [self fireMissile];

	
	CGFloat forwardMag = [[BBSceneController sharedSceneController].inputController forwardMagnitude] * THRUST_SPEED_FACTOR;
	if (forwardMag <= 0.0001) return; // we are not moving so return early
	
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	// now we need to do the thrusters
	// figure out the components of the speed
	speed.x += sinf(radians) * -forwardMag;
	speed.y += cosf(radians) * forwardMag;
}

- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	// if we did not hit a rock, then get out early
	if (![sceneObject isKindOfClass:[BBRock class]]) return;
	// OK, we really want to make sure that we were hit.
	// so we are going to do a secondary check to make sure one of our vertexes is inside the
	// collision radius of the rock
	if (![sceneObject.collider doesCollideWithMesh:self]) return;
	
	// we did hit a rock! smash it!
	[(BBRock*)sceneObject smash];
	// now destroy ourself
	[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
}

@end
