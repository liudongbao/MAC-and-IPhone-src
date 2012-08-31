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
#import "Ship.h"


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
        // create a random angle and calculate and use
        // it so that not all bullets float in one line
        // the velocity is in pixels / second
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		velocity = CGPointMake(100, spread*100);
	
        // remember the right border of the screen
        // we use this to remove the bullet from the scene
		outsideScreen = [[CCDirector sharedDirector] winSize].width;
		
        // set the start position of the bullet
        // which is in the lower part of the ship
		self.position = CGPointMake(ship.position.x + 45, ship.position.y - 19);
		
        // run "update" with every frame redraw
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) update:(ccTime)delta
{
    // update position of the bullet
    // multiply the velocity by the time since the last update was called
    // this ensures same bullet velocity even if frame rate drops
	self.position = ccpAdd(self.position, ccpMult(velocity, delta));
	
    // delete the bullet if it leaves the screen
	if (self.position.x > outsideScreen)
	{
		[self removeFromParentAndCleanup:YES];
	}
}

@end
