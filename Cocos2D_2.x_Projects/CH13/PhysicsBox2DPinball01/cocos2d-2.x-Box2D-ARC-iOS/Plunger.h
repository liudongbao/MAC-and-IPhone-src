//
//  Plunger.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"

@interface Plunger : BodySprite
{
	b2PrismaticJoint* joint;
}

+(id) plungerWithWorld:(b2World*)world;
@end
