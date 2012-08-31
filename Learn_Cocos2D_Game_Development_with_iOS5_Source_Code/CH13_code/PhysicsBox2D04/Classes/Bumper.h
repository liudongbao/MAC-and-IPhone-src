//
//  Bumper.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "BodyNode.h"

@interface Bumper : BodyNode
{
}

+(id) bumperWithWorld:(b2World*)world position:(CGPoint)pos;

@end
