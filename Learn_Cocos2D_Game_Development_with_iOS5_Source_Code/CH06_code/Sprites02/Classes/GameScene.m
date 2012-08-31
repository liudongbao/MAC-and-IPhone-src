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
		
        // add a background image
		CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
		background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		[self addChild:background];
		
        // add the ship
		Ship* ship = [Ship ship];
		ship.position = CGPointMake(80, screenSize.height / 2);
		[self addChild:ship z:10];
		
        // call "update" for every frame
		[self schedule:@selector(countBullets:) interval:3];
	}
	return self;
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
