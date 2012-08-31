//
//  Plunger.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"
#import "b2PrismaticJoint.h"

@interface Plunger : BodyNode
{
	b2PrismaticJoint* joint;
}

+(id) plungerWithWorld:(b2World*)world;

@end
