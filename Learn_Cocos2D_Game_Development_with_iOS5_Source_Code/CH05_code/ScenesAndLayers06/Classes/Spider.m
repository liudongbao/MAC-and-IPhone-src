//
//  Spider.m
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 29.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Spider.h"
#import "MultiLayerScene.h"


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
		[parentNode addChild:self];
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];

		spiderSprite = [CCSprite spriteWithFile:@"spider.png"];
		spiderSprite.position = CGPointMake(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height);
		[self addChild:spiderSprite];

		[self scheduleUpdate];

		// Manually add this class as receiver of targeted touch events.
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
	}
	
	return self;
}

-(void) dealloc
{
	// Must manually remove this class as touch input receiver!
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super dealloc];
}

// Extract common logic into a separate method accepting parameters.
-(void) moveAway:(float)duration position:(CGPoint)moveTo
{
	[spiderSprite stopAllActions];
	CCMoveBy* move = [CCMoveBy actionWithDuration:duration position:moveTo];
	[spiderSprite runAction:move];
}

-(void) update:(ccTime)delta
{
	numUpdates++;
	if (numUpdates > 50)
	{
		numUpdates = 0;
		
		// Move at regular speed.
		CGPoint moveTo = CGPointMake(CCRANDOM_0_1() * 200 - 100, CCRANDOM_0_1() * 100 - 50);
		[self moveAway:2 position:moveTo];
	}
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [MultiLayerScene locationFromTouch:touch];
	
	// Check if this touch is on the Spider's sprite.
	BOOL isTouchHandled = CGRectContainsPoint([spiderSprite boundingBox], touchLocation);
	if (isTouchHandled)
	{
		// Reset move counter.
		numUpdates = 0;
		
		// Move away from touch loation rapidly.
		CGPoint moveTo;
		float moveDistance = 60;
		float rand = CCRANDOM_0_1();

		// Randomly pick one of four corners to move away to.
		if (rand < 0.25f)
			moveTo = CGPointMake(moveDistance, moveDistance);
		else if (rand < 0.5f)
			moveTo = CGPointMake(-moveDistance, moveDistance);
		else if (rand < 0.75f)
			moveTo = CGPointMake(moveDistance, -moveDistance);
		else
			moveTo = CGPointMake(-moveDistance, -moveDistance);
		
		[self moveAway:0.1f position:moveTo];
	}

	return isTouchHandled;
}

@end
