//
//  Bullet.m
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

#import "Bullet.h"


@implementation Bullet

@synthesize velocity;

-(id) init
{
	if ((self = [super init]))
	{
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		velocity = CGPointMake(1, spread);
	
		outsideScreen = [[CCDirector sharedDirector] winSize].width;
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
	self.position = ccpAdd(self.position, velocity);
	
	if (self.position.x > outsideScreen)
	{
		[self removeFromParentAndCleanup:YES];
	}
}

@end
