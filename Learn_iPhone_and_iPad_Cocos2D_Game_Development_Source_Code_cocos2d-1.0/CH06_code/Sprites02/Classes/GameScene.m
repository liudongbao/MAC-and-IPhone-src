//
//  GameScene.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "Ship.h"

@interface GameScene (PrivateMethods)
-(void) countBullets:(ccTime)delta;
@end

@implementation GameScene

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
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
		[self addChild:colorLayer z:-1];
		
		CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
		background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		[self addChild:background];
		
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(ship.texture.contentSize.width / 2, screenSize.height / 2);
		[self addChild:ship];
		
		[self schedule:@selector(countBullets:) interval:3];
	}
	return self;
}

-(void) dealloc
{
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) countBullets:(ccTime)delta
{
	int numBullets = 0;
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		if (node.tag == GameSceneNodeTagBullet)
		{
			numBullets++;
		}
	}
	
	CCLOG(@"Number of active Bullets: %i", numBullets);
}

@end
