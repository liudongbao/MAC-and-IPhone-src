//
//  Spider.m
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 29.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Spider.h"


@implementation Spider

// Static autorelease initializer, mimics cocos2d's memory allocation scheme.
+(id) spiderWithParentNode:(CCNode*)parentNode
{
	return [[[self alloc] initWithParentNode:parentNode] autorelease];
}

-(id) initWithParentNode:(CCNode*)parentNode
{
	if ((self = [super init]))
	{
		// add yourself to the parent
		[parentNode addChild:self];
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];

		spiderSprite = [CCSprite spriteWithFile:@"spider.png"];
		spiderSprite.position = CGPointMake(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height);

		// add the spiderSprite to yourself
		[self addChild:spiderSprite];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
	numUpdates++;
	if (numUpdates > 50)
	{
		numUpdates = 0;
		[spiderSprite stopAllActions];
		
		CGPoint moveTo = CGPointMake(CCRANDOM_0_1() * 200 - 100, CCRANDOM_0_1() * 100 - 50);
		CCMoveBy* move = [CCMoveBy actionWithDuration:1 position:moveTo];
		[spiderSprite runAction:move];
	}
}

@end
