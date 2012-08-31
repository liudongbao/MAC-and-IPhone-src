//
//  BodyNode.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 21.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Helper.h"
#import "Constants.h"
#import "PinballTable.h"
#import "Box2D.h"
#import "b2Body.h"

@interface BodyNode : CCSprite 
{
	b2Body* body;
}

@property (readonly, nonatomic) b2Body* body;

/**
 * Creates a new shape
 * @param shapeName: Name of the shape and sprite
 * @param inWorld: Pointer to the world object to add the sprite to
 * @return BodyNode object
 */
-(id) initWithShape:(NSString*)shapeName inWord:(b2World*)world;

/**
 * Changes the body's shape
 * Removes the fixtures of the body replacing them
 * with the new ones
 * @param shapeName name of the shape to set
 */
-(void) setBodyShape:(NSString*)shapeName;

@end
