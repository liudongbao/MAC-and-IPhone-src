//
//  StandardMoveComponent.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "StandardMoveComponent.h"
#import "Entity.h"
#import "GameScene.h"

@implementation StandardMoveComponent

-(id) init
{
	if ((self = [super init]))
	{
		velocity = CGPointMake(-1, 0);
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
			[entity setPosition:ccpAdd(entity.position, velocity)];
		}
	}
}

@end
