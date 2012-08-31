//
//  PinballTable.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "cocos2d.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "Box2D.h"
#import "b2World.h"

@interface PinballTable : CCLayer
{
	b2World* world;
	ContactListener* contactListener;
	
	GLESDebugDraw* debugDraw;
}

+(id) scene;

@end
