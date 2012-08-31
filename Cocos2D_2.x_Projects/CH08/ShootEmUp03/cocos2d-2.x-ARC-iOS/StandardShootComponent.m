//
//  StandardShootComponent.m
//  ShootEmUp
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

#import "StandardShootComponent.h"
#import "BulletCache.h"
#import "GameLayer.h"

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

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		updateCount += delta;
		
		if (updateCount >= shootFrequency)
		{
			//CCLOG(@"enemy %@ shoots!", self.parent);
			updateCount = 0;
			
			GameLayer* game = [GameLayer sharedGameLayer];
			CGPoint startPos = ccpSub(self.parent.position, CGPointMake(self.parent.contentSize.width * 0.5f, 0));
			[game.bulletCache shootBulletFrom:startPos velocity:CGPointMake(-200, 0) frameName:bulletFrameName isPlayerBullet:NO];
		}
	}
}

@end
