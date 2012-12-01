//
//  BBSceneObject.m
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneObject.h"
#import "BBSceneController.h"
#import "BBInputViewController.h"
#import "BBCollider.h"

@implementation BBSceneObject

@synthesize translation,rotation,scale,active,mesh,matrix,meshBounds,collider;
@synthesize soundSourceObject;

- (id) init
{
	self = [super init];
	if (self != nil) {
		translation = BBPointMake(0.0, 0.0, 0.0);
		rotation = BBPointMake(0.0, 0.0, 0.0);
		scale = BBPointMake(1.0, 1.0, 1.0);
		matrix = (CGFloat *) malloc(16 * sizeof(CGFloat));
		active = NO;
		meshBounds = CGRectZero;
		self.collider = nil;
		soundSourceObject = [[EWSoundSourceObject alloc] init];
	}
	return self;
}

// called once when the object is first created.
-(void)awake
{

}

-(CGRect) meshBounds
{
	if (CGRectEqualToRect(meshBounds, CGRectZero)) {
		meshBounds = [BBMesh meshBounds:mesh scale:scale];
	}
	return meshBounds;
}

// called once every frame
-(void)update
{
	glPushMatrix();
	glLoadIdentity();
	
	// move to my position
	glTranslatef(translation.x, translation.y, translation.z);
	
	// rotate
	glRotatef(rotation.x, 1.0f, 0.0f, 0.0f);
	glRotatef(rotation.y, 0.0f, 1.0f, 0.0f);
	glRotatef(rotation.z, 0.0f, 0.0f, 1.0f);
	
	//scale
	glScalef(scale.x, scale.y, scale.z);
	// save the matrix transform
	glGetFloatv(GL_MODELVIEW_MATRIX, matrix);
	//restore the matrix
	glPopMatrix();
	if (collider != nil) [collider updateCollider:self];

	[self.soundSourceObject update];
}

// called once every frame
-(void)render
{
	if (!mesh || !active) return; // if we do not have a mesh, no need to render
	// clear the matrix
	glPushMatrix();
	glLoadIdentity();
	glMultMatrixf(matrix);
	[mesh render];	
	glPopMatrix();
}

- (void) soundDidFinishPlaying:(NSNumber*)source_number
{
	[self.soundSourceObject soundDidFinishPlaying:source_number];
}

- (void) dealloc
{
	[mesh release];
	[collider release];
	free(matrix);
	[soundSourceObject release];
	[super dealloc];
}

@end
