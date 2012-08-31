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

#import "GameScene.h"
#import "Ship.h"
#import "Bullet.h"
#import "InputLayer.h"
#import "BulletCache.h"

@interface GameScene (PrivateMethods)
-(void) countBullets:(ccTime)delta;
@end

@implementation GameScene

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
		
		// Load all of the game's artwork up front.
		CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"game-art.plist"];
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		ParallaxBackground* background = [ParallaxBackground node];
		[self addChild:background z:-1];
		
		// add the ship
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(80, screenSize.height / 2);
		[self addChild:ship z:10 tag:GameSceneNodeTagShip];

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

-(Ship*) defaultShip
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagShip];
	NSAssert([node isKindOfClass:[Ship class]], @"node is not a Ship!");
	return (Ship*)node;
}

@end
