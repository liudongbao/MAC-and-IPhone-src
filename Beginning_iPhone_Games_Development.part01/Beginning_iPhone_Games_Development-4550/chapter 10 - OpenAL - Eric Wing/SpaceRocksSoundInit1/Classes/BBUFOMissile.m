//
//  BBUFOMissile.m
//  SpaceRocks3D
//
//  Created by ben smith on 28/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBUFOMissile.h"
#import "BBRock.h"
#import "BBCollider.h"
#import "BBAnimatedQuad.h"
#import "BBParticleSystem.h"
#import "ufoMissile_iphone.h"


@implementation BBUFOMissile
-(void)awake
{
	mesh = [[BBTexturedMesh alloc] initWithVertexes:Mine_vertex_coordinates 
																			vertexCount:Mine_vertex_array_size 
																			 vertexSize:3 
																			renderStyle:GL_TRIANGLES];
	[(BBTexturedMesh*)mesh setMaterialKey:@"ufoMissileTexture"];
	[(BBTexturedMesh*)mesh setUvCoordinates:Mine_texture_coordinates];
	[(BBTexturedMesh*)mesh setNormals:Mine_normal_vectors];
	
	mesh.radius = 0.5;
	mesh.centroid = BBPointMake(0.0, 0.0, 0.0);
	
	self.collider = [BBCollider collider];
	[self.collider setCheckForCollision:YES];
	
	particleEmitter = [[BBParticleSystem alloc] init];
	particleEmitter.emissionRange = BBRangeMake(3.0, 3.0);
	particleEmitter.sizeRange = BBRangeMake(3.0, 1.0);
	particleEmitter.growRange = BBRangeMake(-0.8, 1.0);
	
	particleEmitter.xVelocityRange = BBRangeMake(-2.5, 5.0);
	particleEmitter.yVelocityRange = BBRangeMake(-2.5, 5.0);
	
	particleEmitter.lifeRange = BBRangeMake(0.0, 2.0);
	particleEmitter.decayRange = BBRangeMake(0.05, 0.05);
	
	[particleEmitter setParticle:@"redBlur"];
	particleEmitter.emit = NO;
	
	destroyed = NO;

	emitterOffset = BBPointMake(0, 0, 0);
}


@end
