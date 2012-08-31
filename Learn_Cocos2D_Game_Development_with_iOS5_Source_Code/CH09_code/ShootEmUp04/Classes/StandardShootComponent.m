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
#import "GameScene.h"

#import "SimpleAudioEngine.h"

@implementation StandardShootComponent

@synthesize shootFrequency;
@synthesize bulletFrameName, shootSoundFile;

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
		updateCount += delta;
		
		if (updateCount >= shootFrequency)
		{
			//CCLOG(@"enemy %@ shoots!", self.parent);
			updateCount = 0;
			
			GameScene* game = [GameScene sharedGameScene];
			CGPoint startPos = ccpSub(self.parent.position, CGPointMake(self.parent.contentSize.width * 0.5f, 0));
			[game.bulletCache shootBulletFrom:startPos velocity:CGPointMake(-200, 0) frameName:bulletFrameName isPlayerBullet:NO];
			
			if (shootSoundFile != nil)
			{
				float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
				[[SimpleAudioEngine sharedEngine] playEffect:shootSoundFile pitch:pitch pan:0.0f gain:1.0f];
			}
		}
	}
}

@end
