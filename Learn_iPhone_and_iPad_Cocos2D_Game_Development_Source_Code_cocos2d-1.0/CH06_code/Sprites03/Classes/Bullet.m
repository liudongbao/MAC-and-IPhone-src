//
//  Bullet.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Bullet.h"


@interface Bullet (PrivateMethods)
-(id) initWithShip:(Ship*)ship;
@end


@implementation Bullet

@synthesize velocity;

+(id) bulletWithShip:(Ship*)ship
{
	return [[[self alloc] initWithShip:ship] autorelease];
}

-(id) initWithShip:(Ship*)ship
{
	if ((self = [super initWithFile:@"bullet.png"]))
	{
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		velocity = CGPointMake(1, spread);
	
		outsideScreen = [[CCDirector sharedDirector] winSize].width;
		
		self.position = CGPointMake(ship.position.x + ship.contentSize.width * 0.5f, ship.position.y);
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	
	[super dealloc];
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
