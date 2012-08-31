//
//  Flipper.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"

typedef enum
{
	kFlipperLeft,
	kFlipperRight,
} EFlipperType;

@interface Flipper : BodyNode <CCTargetedTouchDelegate>
{
	EFlipperType type;
	b2RevoluteJoint* joint;
	float totalTime;
}

+(id) flipperWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType;

@end
