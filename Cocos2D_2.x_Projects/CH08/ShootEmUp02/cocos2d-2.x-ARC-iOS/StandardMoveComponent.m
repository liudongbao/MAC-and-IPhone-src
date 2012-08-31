//
//  StandardMoveComponent.m
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

#import "StandardMoveComponent.h"
#import "GameLayer.h"

@implementation StandardMoveComponent

-(id) init
{
	if ((self = [super init]))
	{
		velocity = CGPointMake(-100, 0);
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		if (self.parent.position.x > screenSize.width * 0.5f)
		{
			self.parent.position = ccpAdd(self.parent.position, ccpMult(velocity, delta));
		}
	}
}

@end
