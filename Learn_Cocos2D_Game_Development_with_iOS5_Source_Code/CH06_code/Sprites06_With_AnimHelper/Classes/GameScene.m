//
//  GameScene.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "Ship.h"
#import "Bullet.h"

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
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
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
		
        // add a background image
		CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
		background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		[self addChild:background];
		
        // add the ship
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(80, screenSize.height / 2);
		[self addChild:ship z:1];
		
        // add the batch node
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"bullet.png"];
		[self addChild:batch z:0 tag:GameSceneNodeTagBulletSpriteBatch];

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
	CCLOG(@"Number of active Bullets: %i", [self.bulletSpriteBatch.children count]);
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

@end
