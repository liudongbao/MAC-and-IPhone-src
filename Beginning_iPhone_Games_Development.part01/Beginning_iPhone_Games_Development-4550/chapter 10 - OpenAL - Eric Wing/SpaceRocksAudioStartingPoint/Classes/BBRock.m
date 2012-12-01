//
//  BBRock.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBRock.h"
#import "BBCollider.h"
#import "BBAnimation.h"
#import "BBParticleSystem.h"
#import "rock_iphone.h"


@implementation BBRock

@synthesize smashCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		smashCount = 0;
	}
	return self;
}

+(BBRock*)randomRock
{
	return [BBRock randomRockWithScale:NSMakeRange(35, 55)];
}

+(BBRock*)randomRockWithScale:(NSRange)scaleRange
{
	BBRock * rock = [[BBRock alloc] init];
	CGFloat scale = RANDOM_INT(scaleRange.location,NSMaxRange(scaleRange)); 
	rock.scale = BBPointMake(scale, scale, scale); 
	CGFloat x = RANDOM_INT(100,230);
	NSInteger flipX = RANDOM_INT(1,10);
	if (flipX <= 5) x *= -1.0;
	CGFloat y = RANDOM_INT(0,320) - 160;
	rock.translation = BBPointMake(x, y, 0.0);
	// the rocks will be moving either up or down in the y axis
	CGFloat speed = RANDOM_INT(1,100)/100.0 * 60.0;
	NSInteger flipY = RANDOM_INT(1,10);
	if (flipY <= 5) speed *= -1.0;
	rock.speed = BBPointMake(0.0, speed, 0.0);
	
	CGFloat rotSpeed = RANDOM_INT(1,100)/200.0 * 60.0;
	NSInteger flipRot = RANDOM_INT(1,10);
	if (flipRot <= 5) rotSpeed *= -1.0;
	rock.rotationalSpeed = BBPointMake(rotSpeed, rotSpeed, rotSpeed);
	return [rock autorelease];	
}

-(void)awake
{
	mesh = [[BBTexturedMesh alloc] initWithVertexes:Rock_vertex_coordinates 
																			vertexCount:Rock_vertex_array_size 
																			 vertexSize:3 
																			renderStyle:GL_TRIANGLES];
	[(BBTexturedMesh*)mesh setMaterialKey:@"rockTexture"];
	[(BBTexturedMesh*)mesh setUvCoordinates:Rock_texture_coordinates];
	[(BBTexturedMesh*)mesh setNormals:Rock_normal_vectors];
	
	mesh.radius = 0.5;
	
	self.collider = [BBCollider collider];
	
	particleEmitter = [[BBParticleSystem alloc] init];
	particleEmitter.emissionRange = BBRangeMake(50.0, 0.0);
	
	if (smashCount == 0) {
		particleEmitter.sizeRange = BBRangeMake(18.0, 3.0);		
	} else {
		particleEmitter.sizeRange = BBRangeMake(8.0, 3.0);		
	}
	
	particleEmitter.growRange = BBRangeMake(-0.8, 0.5);
	
	particleEmitter.xVelocityRange = BBRangeMake(-2, 4);
	particleEmitter.yVelocityRange = BBRangeMake(-2, 4);
	
	particleEmitter.lifeRange = BBRangeMake(0.0, 5.5);
	particleEmitter.decayRange = BBRangeMake(0.03, 0.05);

	[particleEmitter setParticle:@"greenBlur"];
	particleEmitter.emit = YES;
	particleEmitter.emitCounter = 6;
	
	smashed = NO;
}


-(void)smash
{
	smashCount++;
	smashed = YES;
	self.active = NO;
	self.collider = nil;
	self.speed = BBPointMake(0.0, 0.0, 0.0);
	particleEmitter.translation = self.translation;
//	[[BBSceneController sharedSceneController] removeObjectFromScene:self];
	[[BBSceneController sharedSceneController] addObjectToScene:particleEmitter];
	// if we have already been smashed once, then that is it
	if (smashCount >= 2) return;
		
	// need to break ourself apart
	NSInteger smallRockScale = scale.x / 3.0;
	
	BBRock * newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, smallRockScale); 
	// now we need to position it 
	BBPoint position = BBPointMake(0.0, 0.5, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, smallRockScale); 
	// now we need to position it 
	position = BBPointMake(0.35, -0.35, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, smallRockScale); 
	// now we need to position it 
	position = BBPointMake(-0.35, -0.35, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];
	
}

// called once every frame
-(void)update
{
	[super update];
	particleEmitter.translation = self.translation;
	if (!smashed) return;
	
	if ((particleEmitter.emitCounter <= 0) && (![particleEmitter activeParticles])) {
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
	}	
}

- (void) dealloc
{
	if (particleEmitter != nil) [[BBSceneController sharedSceneController] removeObjectFromScene:particleEmitter];
	[particleEmitter release];
	[super dealloc];
}

@end
