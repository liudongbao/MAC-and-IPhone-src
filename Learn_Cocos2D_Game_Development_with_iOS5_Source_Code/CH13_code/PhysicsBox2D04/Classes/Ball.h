//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"
#import "b2World.h"

@interface Ball : BodyNode <CCTargetedTouchDelegate>
{
	bool moveToFinger;
	CGPoint fingerLocation;
}

/**
 * Creates a new ball
 * @param world world to add the ball to
 */
+(id) ballWithWorld:(b2World*)world;

@end
