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
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		sharedGameLayer = self;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
        // add a background image
		CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
		background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		[self addChild:background];
		
        // add the ship
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(80, screenSize.height / 2);
		[self addChild:ship z:10];
		
        // add the batch node
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"bullet.png"];
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
	sharedGameLayer = nil;
}

-(void) countBullets:(ccTime)delta
{
	CCLOG(@"Number of active Bullets: %i", self.bulletSpriteBatch.children.count);
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
	if (nextInactiveBullet >= bullets.count)
	{
		nextInactiveBullet = 0;
	}
}

@end
