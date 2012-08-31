//
//  GameScene.h
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	GameSceneNodeTagBullet = 1,
	
} GameSceneNodeTags;

@interface GameScene : CCLayer 
{
}

+(id) scene;

@end
