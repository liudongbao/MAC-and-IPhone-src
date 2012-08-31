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

		// Now uses the image from the Texture Atlas.
		CCSpriteFrame* bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"];
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture];
		[self addChild:batch z:1 tag:GameSceneNodeTagBulletSpriteBatch];

		// Create a number of bullets up front and re-use them whenever necessary.
		for (int i = 0; i < 400; i++)
		{
			Bullet* bullet = [Bullet bullet];
			bullet.visible = NO;
			[batch addChild:bullet];
		}
		
		// call bullet countrer from time to time
		[self schedule:@selector(countBullets:) interval:3];
	}
	return self;
}

-(void) dealloc
{
	instanceOfGameScene = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) countBullets:(ccTime)delta
{
	CCLOG(@"Number of active Bullets: %i", [[self.bulletSpriteBatch children] count]);
}

-(CCSpriteBatchNode*) bulletSpriteBatch
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagBulletSpriteBatch];
	NSAssert([node isKindOfClass:[CCSpriteBatchNode class]], @"not a CCSpriteBatchNode");
	return (CCSpriteBatchNode*)node;
}

-(void) shootBulletFromShip:(Ship*)ship
{
	CCArray* bullets = [self.bulletSpriteBatch children];
	
	CCNode* node = [bullets objectAtIndex:nextInactiveBullet];
	NSAssert([node isKindOfClass:[Bullet class]], @"not a bullet!");
	
	Bullet* bullet = (Bullet*)node;
	[bullet shootBulletFromShip:ship];
	
	nextInactiveBullet++;
	if (nextInactiveBullet >= [bullets count])
	{
		nextInactiveBullet = 0;
	}
}

-(Ship*) defaultShip
{
	CCNode* node = [self getChildByTag:GameSceneNodeTagShip];
	NSAssert([node isKindOfClass:[Ship class]], @"node is not a Ship!");
	return (Ship*)node;
}

@end
