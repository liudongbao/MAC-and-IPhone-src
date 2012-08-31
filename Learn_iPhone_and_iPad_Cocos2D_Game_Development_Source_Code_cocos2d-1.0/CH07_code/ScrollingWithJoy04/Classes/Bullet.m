//
//  Bullet.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Bullet.h"


@interface Bullet (PrivateMethods)
-(id) initWithBulletImage;
@end


@implementation Bullet

@synthesize velocity;

+(id) bullet
{
	return [[[self alloc] initWithBulletImage] autorelease];
}

-(id) initWithBulletImage
{
	// Uses the Texture Atlas now.
	if ((self = [super initWithSpriteFrameName:@"bullet.png"]))
	{
	}
	
	return self;
}

-(void) dealloc
{
	
	[super dealloc];
}

// Re-Uses the bullet
-(void) shootBulletFromShip:(Ship*)ship
{
	float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
	velocity = CGPointMake(1, spread);
	
	outsideScreen = [[CCDirector sharedDirector] winSize].width;
	
	self.position = CGPointMake(ship.position.x + [ship contentSize].width * 0.5f, ship.position.y);
	self.visible = YES;
	
	[self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
	self.position = ccpAdd(self.position, velocity);
	
	if (self.position.x > outsideScreen)
	{
		self.visible = NO;
		[self unscheduleAllSelectors];
	}
}

@end
