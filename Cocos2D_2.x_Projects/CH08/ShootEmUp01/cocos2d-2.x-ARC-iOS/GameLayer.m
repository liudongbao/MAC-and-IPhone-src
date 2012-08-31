//
//  GameScene.m
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

#import "GameLayer.h"
#import "Ship.h"
#import "Bullet.h"
#import "ParallaxBackground.h"
#import "InputLayer.h"
#import "BulletCache.h"

@interface GameLayer (PrivateMethods)
-(void) countBullets:(ccTime)delta;
@end

@implementation GameLayer

static GameLayer* sharedGameLayer;
+(GameLayer*) sharedGameLayer
{
	NSAssert(sharedGameLayer != nil, @"GameScene instance not yet initialized!");
	return sharedGameLayer;
}

+(id) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
    InputLayer* inputLayer = [InputLayer node];
    [scene addChild:inputLayer z:1 tag:GameSceneLayerTagInput];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		sharedGameLayer = self;
		
		// if the background shines through we want to be able to see it!
		glClearColor(1, 1, 1, 1);

		// Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"game-art.plist"];

		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		ParallaxBackground* background = [ParallaxBackground node];
		[self addChild:background z:-1];
		
        // add the ship
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(80, screenSize.height / 2);
		ship.tag = GameSceneNodeTagShip;
		[self addChild:ship z:10];
		
		BulletCache* bulletCache = [BulletCache node];
		[self addChild:bulletCache z:1 tag:GameSceneNodeTagBulletCache];
	}
	return self;
}

-(void) dealloc
{
	sharedGameLayer = nil;
}

-(CCSpriteBatchNode*) bulletSpriteBatch
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagBulletSpriteBatch];
	NSAssert([node isKindOfClass:[CCSpriteBatchNode class]], @"not a CCSpriteBatchNode");
	return (CCSpriteBatchNode*)node;
}

-(Ship*) defaultShip
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagShip];
	NSAssert([node isKindOfClass:[Ship class]], @"node is not a Ship!");
	return (Ship*)node;
}

-(BulletCache*) bulletCache
{
    CCNode* node = [self getChildByTag:GameSceneNodeTagBulletCache];
    NSAssert([node isKindOfClass:[BulletCache class]], @"not a BulletCache");
    return (BulletCache*)node;
}

@end
