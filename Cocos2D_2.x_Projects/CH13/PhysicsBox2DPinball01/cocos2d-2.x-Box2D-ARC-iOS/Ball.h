//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"

@interface Ball : BodySprite <CCTargetedTouchDelegate>
{
	BOOL moveToFinger;
	CGPoint fingerLocation;
}

/**
 * Creates a new ball
 * @param world world to add the ball to
 */
+(id) ballWithWorld:(b2World*)world;
@end
