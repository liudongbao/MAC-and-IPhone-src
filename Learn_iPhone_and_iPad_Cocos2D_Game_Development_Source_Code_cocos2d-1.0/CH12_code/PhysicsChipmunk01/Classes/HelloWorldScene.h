//
//  HelloWorldScene.m
//  PhysicsChipmunk
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

enum 
{
	kTagBatchNode = 1,
};

@interface HelloWorld : CCLayer
{
	cpSpace* space;
}

+(id) scene;

@end
