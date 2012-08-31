//
//  Box.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 21.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodyNode.h"

@interface Box : BodyNode 
{
}

+(id) boxWithWorld:(b2World*)world position:(CGPoint)pos;

@end
