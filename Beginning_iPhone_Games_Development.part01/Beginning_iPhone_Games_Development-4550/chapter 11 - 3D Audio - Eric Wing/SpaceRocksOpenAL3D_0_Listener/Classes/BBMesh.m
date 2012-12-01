//
//  BBMesh.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMesh.h"


@implementation BBMesh

@synthesize vertexCount,vertexSize,colorSize,renderStyle,vertexes,colors,centroid,radius;

- (id)initWithVertexes:(CGFloat*)verts 
					 vertexCount:(NSInteger)vertCount 
					vertexSize:(NSInteger)vertSize
					 renderStyle:(GLenum)style;
{
	self = [super init];
	if (self != nil) {
		self.vertexes = verts;
		self.vertexCount = vertCount;
		self.vertexSize = vertSize;
		self.renderStyle = style;
		self.centroid = [self calculateCentroid];
		self.radius = [self calculateRadius];
	}
	return self;
}

-(BBPoint)calculateCentroid
{
	CGFloat xTotal = 0;
	CGFloat yTotal = 0;
	CGFloat zTotal = 0;
	NSInteger index;
	// step through each vertex and add them all up
	for (index = 0; index < vertexCount; index++) {
		NSInteger position = index * vertexSize;
		xTotal += vertexes[position];
		yTotal += vertexes[position + 1];
		if (vertexSize > 2) zTotal += vertexes[position + 2];
	}
	// now average each total over the number of vertexes
//	return BBPointMake(xTotal/(CGFloat)vertexCount, yTotal/(CGFloat)vertexCount, zTotal/(CGFloat)vertexCount);
	return BBPointMake(xTotal/(CGFloat)vertexCount, yTotal/(CGFloat)vertexCount, 0.0);
}

-(CGFloat)calculateRadius
{
	CGFloat rad = 0.0;
	NSInteger index;
	for (index = 0; index < vertexCount; index++) {
		NSInteger position = index * vertexSize;
		BBPoint vert;
		if (vertexSize > 2) {
			vert = BBPointMake(vertexes[position], vertexes[position + 1], vertexes[position + 2]);		
		} else {
			vert = BBPointMake(vertexes[position], vertexes[position + 1], 0.0);
		}
		CGFloat thisRadius = BBPointDistance(centroid, vert);
		if (rad < thisRadius) rad = thisRadius;
	}
	return rad;
}


// called once every frame
-(void)render
{
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	// load arrays into the engine
	glVertexPointer(vertexSize, GL_FLOAT, 0, vertexes);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(colorSize, GL_FLOAT, 0, colors);	
	glEnableClientState(GL_COLOR_ARRAY);
	
	//render
	glDrawArrays(renderStyle, 0, vertexCount);	
}


+(CGRect)meshBounds:(BBMesh*)mesh scale:(BBPoint)scale
{
	if (mesh == nil) return CGRectZero;
	// need to run through my vertexes and find my extremes
	if (mesh.vertexCount < 2) return CGRectZero;
	CGFloat xMin,yMin,xMax,yMax;
	xMin = xMax = mesh.vertexes[0];
	yMin = yMax = mesh.vertexes[1];
	NSInteger index;
	for (index = 0; index < mesh.vertexCount; index++) {
		NSInteger position = index * mesh.vertexSize;
		if (xMin > mesh.vertexes[position] * scale.x) xMin = mesh.vertexes[position] * scale.x;
		if (xMax < mesh.vertexes[position] * scale.x) xMax = mesh.vertexes[position] * scale.x;
		if (yMin > mesh.vertexes[position + 1] * scale.y) yMin = mesh.vertexes[position + 1] * scale.y;
		if (yMax < mesh.vertexes[position + 1] * scale.y) yMax = mesh.vertexes[position + 1] * scale.y;
	}
	CGRect meshBounds = CGRectMake(xMin, yMin, xMax - xMin, yMax - yMin);
	if (CGRectGetWidth(meshBounds) < 1.0) meshBounds.size.width = 1.0;
	if (CGRectGetHeight(meshBounds) < 1.0) meshBounds.size.height = 1.0;
	return meshBounds;
}

- (void) dealloc
{
	[super dealloc];
}



@end
