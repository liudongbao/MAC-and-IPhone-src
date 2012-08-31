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

enum
{
	kTagBatchNode,
};

@interface HelloWorld : CCLayer
{
	b2World* world;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
