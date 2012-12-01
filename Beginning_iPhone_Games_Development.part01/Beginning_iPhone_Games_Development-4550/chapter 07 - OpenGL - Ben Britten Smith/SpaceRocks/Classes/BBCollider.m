//
//  BBCollider.m
//  SpaceRocks
//
//  Created by ben smith on 7/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBCollider.h"
#import "BBSceneObject.h"
#import "BBMesh.h"



#pragma mark circle mesh
static NSInteger BBCircleVertexStride = 2;
static NSInteger BBCircleColorStride = 4;

static NSInteger BBCircleOutlineVertexesCount = 20;
static CGFloat BBCircleOutlineVertexes[40] = {1.0000,0.0000,0.9511,0.3090,0.8090,0.5878,0.5878,0.8090,0.3090,0.9511,0.0000,1.0000,-0.3090,0.9511,-0.5878,0.8090,-0.8090,0.5878,-0.9511,0.3090,-1.0000,0.0000,-0.9511,-0.3090,-0.8090,-0.5878,-0.5878,-0.8090,-0.3090,-0.9511,-0.0000,-1.0000,0.3090,-0.9511,0.5878,-0.8090,0.8090,-0.5878,0.9511,-0.3090};

static CGFloat BBCircleColorValues[80] = 
{1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 
1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0, 1.0,0.0,0.0,1.0} ;



@implementation BBCollider

@synthesize checkForCollision,maxRadius;

+(BBCollider*)collider
{
	BBCollider * collider = [[BBCollider alloc] init];
	if (DEBUG_DRAW_COLLIDERS) {
		collider.active = YES;
		[collider awake];		
	}
	collider.checkForCollision = NO;
	return [collider autorelease];	
}


-(void)updateCollider:(BBSceneObject*)sceneObject
{
	if (sceneObject == nil) return;
	transformedCentroid = BBPointMatrixMultiply([sceneObject mesh].centroid , [sceneObject matrix]);
	translation = transformedCentroid;
	maxRadius = sceneObject.scale.x;
	if (maxRadius < sceneObject.scale.y) 	maxRadius = sceneObject.scale.y;
	if ((maxRadius < sceneObject.scale.z) && ([sceneObject mesh].vertexStride > 2)) maxRadius = sceneObject.scale.z;
	maxRadius *= [sceneObject mesh].radius;

	scale = BBPointMake([sceneObject mesh].radius * sceneObject.scale.x, [sceneObject mesh].radius * sceneObject.scale.y,0.0);
}

-(BOOL)doesCollideWithCollider:(BBCollider*)aCollider
{
	// just need to check the distance between our two points and 
	// our radius
	CGFloat collisionDistance = self.maxRadius + aCollider.maxRadius;
	CGFloat objectDistance = BBPointDistance(self.translation, aCollider.translation);
	if (objectDistance < collisionDistance) return YES;
	return NO;
}

-(BOOL)doesCollideWithMesh:(BBSceneObject*)sceneObject
{
	NSInteger index;
	// step through each vertex of the scene object
	// transform it into real space coordinates
	// and check it against our radius
	for (index = 0; index < sceneObject.mesh.vertexCount; index++) {
		NSInteger position = index * sceneObject.mesh.vertexStride;
		BBPoint vert;
		if (sceneObject.mesh.vertexStride > 2) {
			vert = BBPointMake(sceneObject.mesh.vertexes[position], sceneObject.mesh.vertexes[position + 1], sceneObject.mesh.vertexes[position + 2]);		
		} else {
			vert = BBPointMake(sceneObject.mesh.vertexes[position], sceneObject.mesh.vertexes[position + 1], 0.0);
		}
		vert = BBPointMatrixMultiply(vert , [sceneObject matrix]);
		CGFloat distance = BBPointDistance(self.translation, vert);
		if (distance < self.maxRadius) return YES;
	}
	return NO;
}



#pragma mark Scene Object methods for debugging;

-(void)awake
{
	mesh = [[BBMesh alloc] initWithVertexes:BBCircleOutlineVertexes 
															vertexCount:BBCircleOutlineVertexesCount 
														 vertexStride:BBCircleVertexStride
															renderStyle:GL_LINE_LOOP];
	mesh.colors = BBCircleColorValues;
	mesh.colorStride = BBCircleColorStride;
}


-(void)render
{
	if (!mesh || !active) return; // if we do not have a mesh, no need to render
	// clear the matrix
	glPushMatrix();
	glLoadIdentity();
	glTranslatef(translation.x, translation.y, translation.z);
	glScalef(scale.x, scale.y, scale.z);
	[mesh render];	
	glPopMatrix();
}


- (void) dealloc
{
	[super dealloc];
}

@end
