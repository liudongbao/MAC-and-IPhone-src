//
//  Bumper.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "Bumper.h"

@implementation Bumper

-(id) initWithWorld:(b2World*)world position:(CGPoint)pos
{
	if ((self = [super initWithShape:@"bumper" inWord:world]))
	{
        // set the body position
        body->SetTransform([Helper toMeters:pos], 0.0f);
	}
	return self;
}

+(id) bumperWithWorld:(b2World*)world position:(CGPoint)pos
{
	return [[[self alloc] initWithWorld:world position:pos] autorelease];
}

@end
