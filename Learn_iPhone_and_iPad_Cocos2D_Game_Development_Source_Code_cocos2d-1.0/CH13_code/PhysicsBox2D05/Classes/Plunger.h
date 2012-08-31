//
//  Plunger.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"

@interface Plunger : BodyNode
{
	b2PrismaticJoint* joint;
	bool doPlunge;
	ccTime plungeTime;
}

@property (nonatomic) bool doPlunge;

+(id) plungerWithWorld:(b2World*)world;

@end
