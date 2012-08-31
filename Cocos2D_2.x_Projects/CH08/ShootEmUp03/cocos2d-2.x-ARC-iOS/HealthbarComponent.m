//
//  HealthbarComponent.m
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

#import "HealthbarComponent.h"
#import "Enemy.h"

@implementation HealthbarComponent

-(void) onEnter
{
	[super onEnter];
	
	[self scheduleUpdate];
}

-(void) reset
{
	float parentWidthHalf = self.parent.contentSize.width / 2;
	float parentHeight = self.parent.contentSize.height;
	float selfHeight = self.contentSize.height;
	self.position = CGPointMake(parentWidthHalf, parentHeight + selfHeight);
	//CCLOG(@"position = %.1f, %.1f", self.position.x, self.position.y);
	self.scaleX = 1.0f;
	self.visible = YES;
}

-(void) update:(ccTime)delta
{
	if (self.parent.visible)
	{
		NSAssert([self.parent isKindOfClass:[Enemy class]], @"parent not an Enemy");
		Enemy* enemy = (Enemy*)self.parent;
		self.scaleX = enemy.hitPoints / (float)enemy.initialHitPoints;
	}
	else if (self.visible)
	{
		self.visible = NO;
	}
}

@end
