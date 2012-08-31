//
//  Ship.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Ship.h"
#import "Bullet.h"
#import "GameScene.h"

@interface Ship (PrivateMethods)
-(id) initWithShipImage;
@end


@implementation Ship

+(id) ship
{
	return [[[self alloc] initWithShipImage] autorelease];
}

-(id) initWithShipImage
{
	if ((self = [super initWithFile:@"ship.png"]))
	{
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) update:(ccTime)delta
{
	// Shooting is relayed to the game scene
	[[GameScene sharedGameScene] shootBulletFromShip:self];
}

@end
