//
//  GameScene.h
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "BulletCache.h"
#import "ParallaxBackground.h"
#import "ShipEntity.h"

typedef enum
{
	GameSceneLayerTagGame = 1,
	GameSceneLayerTagInput,
	
} GameSceneLayerTags;

typedef enum
{
	GameSceneNodeTagBullet = 1,
	GameSceneNodeTagBulletSpriteBatch,
	GameSceneNodeTagBulletCache,
	GameSceneNodeTagEnemyCache,
	GameSceneNodeTagShip,
	
} GameSceneNodeTags;


@interface GameScene : CCLayer 
{

}

+(id) scene;
+(GameScene*) sharedGameScene;

-(ShipEntity*) defaultShip;

@property (readonly, nonatomic) BulletCache* bulletCache;

+(CGRect) screenRect;

@end
