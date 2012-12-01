//
//  BBRock.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBRock.h"
#import "BBCollider.h"

#pragma mark Rocks mesh
// the rocks are going to be randomly generated
// so we just need some basic info about them
static NSInteger BBRockVertexStride = 2;
static NSInteger BBRockColorStride = 4;
static NSInteger BBRockOutlineVertexesCount = 16;

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
	return [BBRock randomRockWithScale:NSMakeRange(15, 20)];
}

+(BBRock*)randomRockWithScale:(NSRange)scaleRange
{
	BBRock * rock = [[BBRock alloc] init];
	CGFloat scale = RANDOM_INT(scaleRange.location,NSMaxRange(scaleRange)); 
	rock.scale = BBPointMake(scale, scale, 1.0); 
	CGFloat x = RANDOM_INT(100,230);
	NSInteger flipX = RANDOM_INT(1,10);
	if (flipX <= 5) x *= -1.0;
	CGFloat y = RANDOM_INT(0,320) - 160;
	rock.translation = BBPointMake(x, y, 0.0);
	// the rocks will be moving either up or down in the y axis
	CGFloat speed = RANDOM_INT(1,100)/100.0;
	NSInteger flipY = RANDOM_INT(1,10);
	if (flipY <= 5) speed *= -1.0;
	rock.speed = BBPointMake(0.0, speed, 0.0);
	
	CGFloat rotSpeed = RANDOM_INT(1,100)/200.0;
	NSInteger flipRot = RANDOM_INT(1,10);
	if (flipRot <= 5) rotSpeed *= -1.0;
	rock.rotationalSpeed = BBPointMake(0.0, 0.0, rotSpeed);
	return [rock autorelease];	
}

-(void)awake
{
	// pick a random number of vertexes, more than 8, less than the max count
	NSInteger myVertexCount = RANDOM_INT(8,BBRockOutlineVertexesCount);
	
	// malloc some memory for our vertexes and colors
	verts = (CGFloat *) malloc(myVertexCount * BBRockVertexStride * sizeof(CGFloat));
	colors = (CGFloat *) malloc(myVertexCount * BBRockColorStride * sizeof(CGFloat));
	
	// we need to use radians for our angle since we wil be using the trig functions
	CGFloat radians = 0.0;
	CGFloat radianIncrement = (2.0 * 3.14159) / (CGFloat)myVertexCount;

	// generate the vertexes
	NSInteger vertexIndex = 0;
	for (vertexIndex = 0; vertexIndex < myVertexCount; vertexIndex++) {
		NSInteger position = vertexIndex * BBRockVertexStride;
		// ranom radial adjustment
		CGFloat radiusAdjust = 0.25 - (RANDOM_INT(1,100)/100.0 * 0.5);
		// calculate the point on the circel, but vary the radius
		verts[position] = cosf(radians) * (1.0 + radiusAdjust);
    verts[position + 1] = sinf(radians) * (1.0 + radiusAdjust);
		// move on to the next angle
		radians += radianIncrement;
	}
	
	// now the colors, just make it white for now, all 1's
	for (vertexIndex = 0; vertexIndex < myVertexCount * BBRockColorStride; vertexIndex++) {
		colors[vertexIndex] = 1.0;
	}
	
	// now alloc our mesh with our random verts
	mesh = [[BBMesh alloc] initWithVertexes:verts 
															vertexCount:myVertexCount 
														 vertexStride:BBRockVertexStride
															renderStyle:GL_LINE_LOOP];
	
	mesh.colors = colors;
	mesh.colorStride = BBRockColorStride;
	
	self.collider = [BBCollider collider];
}

-(void)smash
{
	smashCount++;
	// queue myself for removal
	[[BBSceneController sharedSceneController] removeObjectFromScene:self];

	// if we have already been smashed once, then that is it
	if (smashCount >= 2) return;
		
	// need to break ourself apart
	NSInteger smallRockScale = scale.x / 3.0;
	
	BBRock * newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
	// now we need to position it 
	BBPoint position = BBPointMake(0.0, 0.5, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
	// now we need to position it 
	position = BBPointMake(0.35, -0.35, 0.0);
	newRock.translation = BBPointMatrixMultiply(position , matrix);
	newRock.speed = BBPointMake(speed.x + (position.x * SMASH_SPEED_FACTOR), speed.y + (position.y * SMASH_SPEED_FACTOR), 0.0);
	newRock.rotationalSpeed = rotationalSpeed;
	newRock.smashCount = smashCount;
	[[BBSceneController sharedSceneController] addObjectToScene:newRock];
	[newRock release];

	newRock = [[BBRock alloc] init];
	newRock.scale = BBPointMake(smallRockScale, smallRockScale, 1.0); 
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
}

- (void) dealloc
{
	if (verts) free(verts);
	if (colors) free(colors);
	[super dealloc];
}

@end
