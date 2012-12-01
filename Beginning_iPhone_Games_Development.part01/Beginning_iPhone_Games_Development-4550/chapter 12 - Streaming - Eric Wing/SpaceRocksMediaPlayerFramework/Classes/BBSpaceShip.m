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
#import "ship_iphone.h"
#import "BBParticleSystem.h"
#import "EWSoundListenerObject.h"

@interface BBSpaceShip ()
@property(nonatomic, retain) EWSoundListenerObject* soundListenerObject;
@end


@implementation BBSpaceShip

@synthesize soundListenerObject;

+ (void) loadResources
{
	[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:THRUST1];
	[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:EXPLOSION3];
}

// called once when the object is first created.
-(void)awake
{
	[super awake];
	mesh = [[BBTexturedMesh alloc] initWithVertexes:Ship_vertex_coordinates 
																			vertexCount:Ship_vertex_array_size 
																			 vertexSize:3 
																			renderStyle:GL_TRIANGLES];
	[(BBTexturedMesh*)mesh setMaterialKey:@"shipTexture"];
	[(BBTexturedMesh*)mesh setUvCoordinates:Ship_texture_coordinates];
	[(BBTexturedMesh*)mesh setNormals:Ship_normal_vectors];
	
	mesh.radius = 0.75;
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
	dead = NO;
	
	
	particleEmitter = [[BBParticleSystem alloc] init];
	particleEmitter.emissionRange = BBRangeMake(3.0, 0.0);
	particleEmitter.sizeRange = BBRangeMake(8.0, 1.0);
	particleEmitter.growRange = BBRangeMake(-0.8, 0.5);
	xVeloRange = BBRangeMake(-0.5, 1.0);
	yVeloRange = BBRangeMake(-0.5, 1.0);
	particleEmitter.xVelocityRange = xVeloRange;
	particleEmitter.yVelocityRange = yVeloRange;

	
	particleEmitter.lifeRange = BBRangeMake(0.0, 2.5);
	particleEmitter.decayRange = BBRangeMake(0.03, 0.05);
	
	[particleEmitter setParticle:@"lightBlur"];
	particleEmitter.emit = YES;
	[[BBSceneController sharedSceneController] addObjectToScene:particleEmitter];
//	particleEmitter.emitCounter = 4;
	
//	secondaryColliders = [[NSMutableArray alloc] init];
//	BBCollider * secondaryCollider1 = [BBCollider collider];
//	secondaryCollider1
	explosionDidEnd = NO;
	self.soundSourceObject.audioLooping = AL_TRUE;
	
	soundListenerObject	= [[EWSoundListenerObject alloc] init];
//	soundListenerObject.gainLevel = 1.0;  // Change this value if you want to play with the listener volume
	soundListenerObject.objectPosition = translation;
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	self.soundListenerObject.atOrientation = BBPointMake(-sinf(radians), cosf(radians), 0.0);
}


-(void)fireMissile
{
	// need to spawn a missile
	BBMissile * missile = [[BBMissile alloc] init];
	missile.scale = BBPointMake(5, 5, 5);
	// we need to position it at the tip of our ship
	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	CGFloat speedX = -sinf(radians) * 3.0 * 60;
	CGFloat speedY = cosf(radians) * 3.0 * 60;

	missile.speed = BBPointMake(speedX, speedY, 0.0);
	
	missile.translation = BBPointMatrixMultiply(BBPointMake(0.0, 1.0, 0.0), matrix);
//	missile.translation = BBPointMake(translation.x + missile.speed.x * 3.0, translation.y + missile.speed.y * 3.0, 0.0);
	missile.rotation = BBPointMake(0.0, 0.0, self.rotation.z);

	[[BBSceneController sharedSceneController] addObjectToScene:missile];
	[missile release];
	
	[[BBSceneController sharedSceneController].inputController setFireMissile:NO];
}


// called once every frame
-(void)update
{
	[super update];
	if (dead) {
		[self deadUpdate];
		return;		
	}

	particleEmitter.translation = BBPointMatrixMultiply(BBPointMake(0.0, -0.4, 0.0), matrix);

	CGFloat radians = rotation.z/BBRADIANS_TO_DEGREES;
	CGFloat speedX = sinf(radians);
	CGFloat speedY = -cosf(radians);
	particleEmitter.xVelocityRange = BBRangeMake(speedX * 2 , speedX * 2);
	particleEmitter.yVelocityRange = BBRangeMake(speedY * 2 , speedY * 2);	
	
	
	CGFloat rightTurn = [[BBSceneController sharedSceneController].inputController rightMagnitude];
	CGFloat leftTurn = [[BBSceneController sharedSceneController].inputController leftMagnitude];

	rotation.z += ((rightTurn * -1.0) + leftTurn) * TURN_SPEED_FACTOR * 2.0;
	
	if ([[BBSceneController sharedSceneController].inputController fireMissile]) [self fireMissile];

	
	CGFloat forwardMag = [[BBSceneController sharedSceneController].inputController forwardMagnitude]  * THRUST_SPEED_FACTOR;
	particleEmitter.emissionRange = BBRangeMake([[BBSceneController sharedSceneController].inputController forwardMagnitude] * 5, [[BBSceneController sharedSceneController].inputController forwardMagnitude] * 5);
	if (forwardMag <= 0.0001)
	{
		if(YES == isThrusting)
		{
			[self.soundSourceObject stopSound];
		}
		isThrusting = NO;
//		return; // we are not moving so return early
		forwardMag = 0.0;
	}
	else
	{
		if(NO == isThrusting)
		{
			[self.soundSourceObject playSound:[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:THRUST1]];
		}
		isThrusting = YES;
	}
	
	// now we need to do the thrusters
	// figure out the components of the speed
	speed.x += sinf(radians) * -forwardMag;
	speed.y += cosf(radians) * forwardMag;
	
	self.soundListenerObject.objectPosition = translation;
	self.soundListenerObject.atOrientation = BBPointMake(-sinf(radians), cosf(radians), 0.0);
	[self.soundListenerObject update];
}

-(void)deadUpdate
{
	if ((particleEmitter.emitCounter <= 0) && (![particleEmitter activeParticles])) {
		self.active = NO;
	}
	if(YES == explosionDidEnd) 
	{
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
		[[BBSceneController sharedSceneController] gameOver];
	}
}

- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	if(dead)
	{
		return;
	}
	// if we did not hit a rock, then get out early
	// ok, since this is the character, we need to do one more check
	// we will define our ship as three smaller collision spheres

	if ([sceneObject isKindOfClass:[BBMissile class]]) {
		[(BBMissile*)sceneObject handleCollision];		
	} else {
		// if it is not a missile, then it might be a close call, need to check
		if (![sceneObject.collider doesCollideWithMesh:self]) return;		
	}

	[self handleCollision];
}


-(void)handleCollision
{
	self.speed = BBPointMake(0.0, 0.0, 0.0);
	self.rotationalSpeed = BBPointMake(0.0, 0.0, 0.0);
	particleEmitter.emissionRange = BBRangeMake(80.0, 10.0);
	particleEmitter.sizeRange = BBRangeMake(10.0, 5.0);
	particleEmitter.growRange = BBRangeMake(-0.5, 0.3);
	particleEmitter.xVelocityRange = BBRangeMake(-2, 4);
	particleEmitter.yVelocityRange = BBRangeMake(-2, 4);
	particleEmitter.lifeRange = BBRangeMake(0.0, 6.5);
	particleEmitter.decayRange = BBRangeMake(0.03, 0.05);

	particleEmitter.emitCounter = 10;
	self.active = NO;
	self.collider = nil;
	dead = YES;
	particleEmitter.translation = self.translation;

	// Stop engine thrust
	[self.soundSourceObject stopSound];
	// Play ship explosion
	self.soundSourceObject.audioLooping = AL_FALSE;
	[self.soundSourceObject playSound:[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:EXPLOSION3]];
	explosionDidEnd = NO;
	explosionID = self.soundSourceObject.sourceID;
}

- (void) dealloc
{

	if (particleEmitter != nil) [[BBSceneController sharedSceneController] removeObjectFromScene:particleEmitter];
	[particleEmitter release];

	[soundListenerObject release];
	[super dealloc];
}

- (void) soundDidFinishPlaying:(NSNumber*)source_number
{
	[super soundDidFinishPlaying:source_number];

	if([source_number unsignedIntValue] == explosionID)
	{
		explosionDidEnd = YES;
	}
}

@end
