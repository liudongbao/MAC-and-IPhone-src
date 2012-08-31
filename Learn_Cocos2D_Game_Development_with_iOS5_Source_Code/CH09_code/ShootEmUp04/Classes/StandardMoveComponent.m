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
#import "Entity.h"
#import "GameScene.h"

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
		NSAssert([self.parent isKindOfClass:[Entity class]], @"node is not a Entity");
		
		Entity* entity = (Entity*)self.parent;
		if (entity.position.x > [GameScene screenRect].size.width * 0.5f)
		{
			[entity setPosition:ccpAdd(entity.position, ccpMult(velocity,delta))];
		}
	}
}

@end
