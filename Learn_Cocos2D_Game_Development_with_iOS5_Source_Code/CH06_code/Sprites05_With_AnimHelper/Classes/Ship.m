//
//  Ship.m
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

#import "Ship.h"
#import "Bullet.h"
#import "GameScene.h"

#import "CCAnimationHelper.h"

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
		// The whole shebang is now encapsulated into a helper method.
		NSString* shipAnimName = @"ship-anim";
		CCAnimation* anim = [CCAnimation animationWithFile:shipAnimName frameCount:5 delay:0.08f];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[self runAction:repeat];
		
        // call "update" for every frame		
		[self scheduleUpdate];
	}
	return self;
}

-(void) update:(ccTime)delta
{
	// Shooting is relayed to the game scene
	[[GameScene sharedGameScene] shootBulletFromShip:self];
}

@end
