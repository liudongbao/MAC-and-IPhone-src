//
//  BBTexturedButton.m
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBTexturedButton.h"


@implementation BBTexturedButton

- (id) initWithUpKey:(NSString*)upKey downKey:(NSString*)downKey
{
	self = [super init];
	if (self != nil) {
		upQuad = [[BBMaterialController sharedMaterialController] quadFromAtlasKey:upKey];
		downQuad = [[BBMaterialController sharedMaterialController] quadFromAtlasKey:downKey];
		[upQuad retain];
		[downQuad retain];
	}
	return self;
}

// called once when the object is first created.
-(void)awake
{
	[self setNotPressedVertexes];
	screenRect = [[BBSceneController sharedSceneController].inputController 
								screenRectFromMeshRect:self.meshBounds 
								atPoint:CGPointMake(translation.x, translation.y)];
	// this is a bit rendundant, but allows for much simpler subclassing
}

// called once every frame
-(void)update
{
	// check for touches
	[self handleTouches];
	[super update];
}

-(void)setPressedVertexes
{
	self.mesh = downQuad;
}

-(void)setNotPressedVertexes
{
	self.mesh = upQuad;
}

- (void) dealloc
{
	[upQuad release];
	[downQuad release];
	[super dealloc];
}


@end
