//
//  HelloWorldScene.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "ContactListener.h"

enum
{
	kTagBatchNode,
};

@interface PinballTable : CCLayer
{
	b2World* world;
	ContactListener* contactListener;
	
	GLESDebugDraw* debugDraw;
}

+(PinballTable*) sharedTable;

+(id) scene;

-(CCSpriteBatchNode*) getSpriteBatch;

@end
