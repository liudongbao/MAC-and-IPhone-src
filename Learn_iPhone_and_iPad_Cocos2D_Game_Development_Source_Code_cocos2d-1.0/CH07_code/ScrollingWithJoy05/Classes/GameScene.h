//
//  GameScene.h
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "ParallaxBackground.h"
#import "Ship.h"

typedef enum
{
	GameSceneLayerTagGame = 1,
	GameSceneLayerTagInput,
	
} GameSceneLayerTags;

typedef enum
{
	GameSceneNodeTagBullet = 1,
	GameSceneNodeTagBulletSpriteBatch,
	
} GameSceneNodeTags;

@interface GameScene : CCLayer 
{
	int nextInactiveBullet;

}

+(id) scene;
+(GameScene*) sharedGameScene;

-(void) shootBulletFromShip:(Ship*)ship;

@property (readonly) CCSpriteBatchNode* bulletSpriteBatch;

@end
