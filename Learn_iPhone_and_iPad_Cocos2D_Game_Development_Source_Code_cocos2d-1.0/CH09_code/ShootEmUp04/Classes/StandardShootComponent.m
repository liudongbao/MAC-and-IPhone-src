//
//  StandardShootComponent.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "StandardShootComponent.h"
#import "BulletCache.h"
#import "GameScene.h"

@implementation StandardShootComponent

@synthesize shootFrequency;
@synthesize bulletFrameName;

-(id) init
{
	if ((self = [super init]))
	{
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[bulletFrameName release];
	[super dealloc];
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		updateCount++;
		
		if (updateCount >= shootFrequency)
		{
			//CCLOG(@"enemy %@ shoots!", self.parent);
			updateCount = 0;
			
			GameScene* game = [GameScene sharedGameScene];
			CGPoint startPos = ccpSub(self.parent.position, CGPointMake(self.parent.contentSize.width * 0.5f, 0));
			[game.bulletCache shootBulletFrom:startPos velocity:CGPointMake(-2, 0) frameName:bulletFrameName isPlayerBullet:NO];
		}
	}
}

@end
