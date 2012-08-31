//
//  GameScene.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "Bullet.h"
#import "InputLayer.h"
#import "BulletCache.h"
#import "EnemyCache.h"

@interface GameScene (PrivateMethods)
-(void) countBullets:(ccTime)delta;
@end

@implementation GameScene

static CGRect screenRect;

static GameScene* instanceOfGameScene;
+(GameScene*) sharedGameScene
{
	NSAssert(instanceOfGameScene != nil, @"GameScene instance not yet initialized!");
	return instanceOfGameScene;
}

+(id) scene
{
	CCScene* scene = [CCScene node];
	GameScene* layer = [GameScene node];
	[scene addChild:layer z:0 tag:GameSceneLayerTagGame];
	InputLayer* inputLayer = [InputLayer node];
	[scene addChild:inputLayer z:1 tag:GameSceneLayerTagInput];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		instanceOfGameScene = self;
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
		
		// Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"game-art.plist"];
		
		ParallaxBackground* background = [ParallaxBackground node];
		[self addChild:background z:-1];
		
		ShipEntity* ship = [ShipEntity ship];
		ship.position = CGPointMake([ship contentSize].width / 2, screenSize.height / 2);
		[self addChild:ship z:0 tag:GameSceneNodeTagShip];
		
		EnemyCache* enemyCache = [EnemyCache node];
		[self addChild:enemyCache z:0 tag:GameSceneNodeTagEnemyCache];

		BulletCache* bulletCache = [BulletCache node];
		[self addChild:bulletCache z:1 tag:GameSceneNodeTagBulletCache];
	}
	return self;
}

-(void) dealloc
{
	instanceOfGameScene = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(BulletCache*) bulletCache
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagBulletCache];
	NSAssert([node isKindOfClass:[BulletCache class]], @"not a BulletCache");
	return (BulletCache*)node;
}

-(ShipEntity*) defaultShip
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagShip];
	NSAssert([node isKindOfClass:[ShipEntity class]], @"node is not a ShipEntity!");
	return (ShipEntity*)node;
}

+(CGRect) screenRect
{
	return screenRect;
}

@end
