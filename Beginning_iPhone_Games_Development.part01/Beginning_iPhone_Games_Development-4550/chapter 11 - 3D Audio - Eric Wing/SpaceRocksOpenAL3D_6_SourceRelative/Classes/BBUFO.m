//
//  BBUFO.m
//  SpaceRocks3D
//
//  Created by ben smith on 31/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBUFO.h"
#import "BBUFOMissile.h"
#import "BBRock.h"
#import "BBCollider.h"
#import "ufo_iphone.h"
#import "BBParticleSystem.h"


@implementation BBUFO
+ (void) loadResources
{
	[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:UFO_ENGINE];
	[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:EXPLOSION3];
}

-(void)awake
{
	[super awake];

	mesh = [[BBTexturedMesh alloc] initWithVertexes:UFO_vertex_coordinates 
																			vertexCount:UFO_vertex_array_size 
																			 vertexSize:3 
																			renderStyle:GL_TRIANGLES];
	[(BBTexturedMesh*)mesh setMaterialKey:@"ufoTexture"];
	[(BBTexturedMesh*)mesh setUvCoordinates:UFO_texture_coordinates];
	[(BBTexturedMesh*)mesh setNormals:UFO_normal_vectors];
	
	mesh.radius = 0.5;
	mesh.centroid = BBPointMake(0.0, 0.0, 0.0);
	
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
	
	particleEmitter = [[BBParticleSystem alloc] init];
	particleEmitter.emissionRange = BBRangeMake(1.0, 0.0);
	particleEmitter.sizeRange = BBRangeMake(8.0, 0.0);
	particleEmitter.growRange = BBRangeMake(-0.5, 0.0);
	
	particleEmitter.xVelocityRange = BBRangeMake(-3.5, 2.0);
	particleEmitter.yVelocityRange = BBRangeMake(0.0, 0.0);
	
	particleEmitter.lifeRange = BBRangeMake(5, 0.0);
	particleEmitter.decayRange = BBRangeMake(0.02, 0.00);

	[particleEmitter setParticle:@"whiteBlur"];
	particleEmitter.emit = NO;
	
	destroyed = NO;
	missileCountDown = RANDOM_INT(25,80);

	self.soundSourceObject.audioLooping = AL_TRUE;
	self.soundSourceObject.gainLevel = 0.3; // the sound is kind of loud, so let's try reducing the gain to not overpower everything
	self.soundSourceObject.coneInnerAngle = 90.0;
	self.soundSourceObject.coneOuterAngle = 270.0;
	self.soundSourceObject.coneOuterGain = 0.50;
	self.soundSourceObject.rolloffFactor = 0.5;
	self.soundSourceObject.referenceDistance = 300.0;
//	self.soundSourceObject.positionalDisabled = YES;

	[self.soundSourceObject playSound:[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:UFO_ENGINE]];
}


// called once every frame
-(void)update
{
	particleEmitter.translation = BBPointMake(self.translation.x - 20, self.translation.y, 0.0);
	if (destroyed) {
		if ((particleEmitter.emitCounter <= 0) && (![particleEmitter activeParticles])) {
			[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
		}		
		return;
	}
	[super update];
	
	missileCountDown--;
	if (missileCountDown <=0 ) {
		[self fireMissile];
		missileCountDown = RANDOM_INT(25,80);
	}
	
	if (!particleEmitter.emit) {
		[[BBSceneController sharedSceneController] addObjectToScene:particleEmitter];
		particleEmitter.emit = YES;
	}
}


-(void)checkArenaBounds
{
	BOOL outOfArena = NO;
	if (translation.x > (300.0 + CGRectGetWidth(self.meshBounds)/2.0)) outOfArena = YES; 	
	if (outOfArena) {
		[self.soundSourceObject stopSound];
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];
	}
}

-(void)fireMissile
{
	// need to spawn a missile
	BBUFOMissile * missile = [[BBUFOMissile alloc] init];
	missile.scale = BBPointMake(10, 10, 10);
	// we need to position it at the tip of our ship
	CGFloat zRot = (CGFloat)(RANDOM_INT(0,180)) + 90.0;
	CGFloat radians = zRot/BBRADIANS_TO_DEGREES;
	CGFloat speedX = -sinf(radians) * 3.0;
	CGFloat speedY = cosf(radians) * 3.0;
	
	missile.speed = BBPointMake(speedX * 60, speedY * 60, 0.0);
	
	missile.translation = BBPointMake(self.translation.x + speedX * 6.0, self.translation.y + speedY * 6.0, 0.0);
	missile.rotation = BBPointMake(0.0, 0.0, zRot);
	missile.rotationalSpeed = BBPointMake(RANDOM_INT(0,130), RANDOM_INT(0,130), RANDOM_INT(0,130));
	
	[[BBSceneController sharedSceneController] addObjectToScene:missile];
	[missile release];
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
	particleEmitter.translation = self.translation;	
	self.active = NO;
	self.collider = nil;
	destroyed = YES;
	
	// Stop engine noise
	[self.soundSourceObject stopSound];
	// Play ship explosion
	self.soundSourceObject.audioLooping = AL_FALSE;
	self.soundSourceObject.gainLevel = 1.0;
	[self.soundSourceObject playSound:[[OpenALSoundController sharedSoundController] soundBufferDataFromFileBaseName:EXPLOSION3]];
}


- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	if ([sceneObject isKindOfClass:[BBRock class]]) return;
	if ([sceneObject isKindOfClass:[BBMissile class]]) [(BBMissile*)sceneObject handleCollision];
	[self handleCollision];
}

- (void) dealloc
{
	if (particleEmitter != nil) [[BBSceneController sharedSceneController] removeObjectFromScene:particleEmitter];
	[particleEmitter release];
	// If the ship is exploding, we want the sound to finish naturally.
	// But if the game is being reset, we don't want the UFO engine to keep humming.
	// So check the looping flag, and if it is looping, stop the sound.
	if(AL_TRUE == self.soundSourceObject.audioLooping)
	{
		[self.soundSourceObject stopSound];		
	}
	[super dealloc];
}

@end
