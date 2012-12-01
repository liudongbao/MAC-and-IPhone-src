//
//  BBMissile.m
//  SpaceRocks
//
//  Created by ben smith on 5/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMissile.h"
#import "BBRock.h"
#import "BBCollider.h"
#import "BBAnimatedQuad.h"
#import "BBParticleSystem.h"
#import "missile_iphone.h"

#pragma mark Missile mesh

@implementation BBMissile

-(void)awake
{
	mesh = [[BBTexturedMesh alloc] initWithVertexes:Missile_vertex_coordinates 
																			vertexCount:Missile_vertex_array_size 
																			 vertexSize:3 
																			renderStyle:GL_TRIANGLES];
	[(BBTexturedMesh*)mesh setMaterialKey:@"missileTexture"];
	[(BBTexturedMesh*)mesh setUvCoordinates:Missile_texture_coordinates];
	[(BBTexturedMesh*)mesh setNormals:Missile_normal_vectors];
	
	mesh.radius = 0.5;
	mesh.centroid = BBPointMake(0.0, 0.0, 0.0);

	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
	
	particleEmitter = [[BBParticleSystem alloc] init];
	particleEmitter.emissionRange = BBRangeMake(3.0, 0.0);
	particleEmitter.sizeRange = BBRangeMake(8.0, 1.0);
	particleEmitter.growRange = BBRangeMake(-0.8, 0.5);

	particleEmitter.xVelocityRange = BBRangeMake(-0.5, 1.0);
	particleEmitter.yVelocityRange = BBRangeMake(-0.5, 1.0);
		
	particleEmitter.lifeRange = BBRangeMake(0.0, 2.5);
	particleEmitter.decayRange = BBRangeMake(0.03, 0.05);

	[particleEmitter setParticle:@"redBlur"];
	particleEmitter.emit = NO;
	
	destroyed = NO;
	
	emitterOffset = BBPointMake(0.0, -2.0, 0.0);
}


// called once every frame
-(void)update
{
	if (destroyed) {
		if ((particleEmitter.emitCounter <= 0) && (![particleEmitter activeParticles])) {
			[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
		}		
		return;
	}
	particleEmitter.translation = BBPointMatrixMultiply(emitterOffset, matrix);
	[super update];

  if (!particleEmitter.emit && active && !destroyed) {
		[[BBSceneController sharedSceneController] addObjectToScene:particleEmitter];
		particleEmitter.emit = YES;
	}
}


-(void)checkArenaBounds
{
	BOOL outOfArena = NO;
	if (translation.x > (300.0 + CGRectGetWidth(self.meshBounds)/2.0)) outOfArena = YES; 
	if (translation.x < (-300.0 - CGRectGetWidth(self.meshBounds)/2.0)) outOfArena = YES; 
	
	if (translation.y > (200.0 + CGRectGetHeight(self.meshBounds)/2.0)) outOfArena = YES; 
	if (translation.y < (-200.0 - CGRectGetHeight(self.meshBounds)/2.0)) outOfArena = YES; 
	
	if (outOfArena) {
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];
	}
}


- (void)didCollideWith:(BBSceneObject*)sceneObject; 
{
	// if we did not hit a rock, then get out early
	if (![sceneObject isKindOfClass:[BBRock class]]) return;
	// OK, we really want to make sure that we were hit.
	// so we are going to do a secondary check to make sure one of our vertexes is inside the
	// collision radius of the rock
	// we did hit a rock! smash it!
	[(BBRock*)sceneObject smash];
	// now destroy ourself
	[self handleCollision];
}

-(void)handleCollision
{
	self.active = NO;
	particleEmitter.emit = NO;
	destroyed = YES;	
	self.collider = nil;
}

- (void) dealloc
{
	if (particleEmitter != nil) [[BBSceneController sharedSceneController] removeObjectFromScene:particleEmitter];	
	[particleEmitter release];
	[super dealloc];
}

@end
