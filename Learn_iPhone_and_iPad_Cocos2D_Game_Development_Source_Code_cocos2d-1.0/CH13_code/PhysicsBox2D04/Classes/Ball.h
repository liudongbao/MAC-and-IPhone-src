//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"

@interface Ball : BodyNode <CCTargetedTouchDelegate>
{
	bool moveToFinger;
	CGPoint fingerLocation;
}

+(id) ballWithWorld:(b2World*)world;

@end
