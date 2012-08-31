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

@class Ship;

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
-(CCSpriteBatchNode*) bulletSpriteBatch;
-(void) shootBulletFromShip:(Ship*)ship;

@end
