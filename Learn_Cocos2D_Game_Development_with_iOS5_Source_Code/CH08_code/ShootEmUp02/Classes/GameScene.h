//
//  GameScene.h
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
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
