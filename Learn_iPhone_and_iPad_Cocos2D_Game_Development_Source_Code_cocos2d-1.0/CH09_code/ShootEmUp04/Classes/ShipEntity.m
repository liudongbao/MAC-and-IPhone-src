//
//  ShipEntity.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 18.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "ShipEntity.h"
#import "CCAnimationHelper.h"
#import "GameScene.h"


@interface ShipEntity (PrivateMethods)
-(id) initWithShipImage;
@end

@implementation ShipEntity

+(id) ship
{
	return [[[self alloc] initWithShipImage] autorelease];
}

-(id) initWithShipImage
{
	// Loading the Ship's sprite using a sprite frame name (eg the filename)
	if ((self = [super initWithSpriteFrameName:@"ship.png"]))
	{
		// create an animation object from all the sprite animation frames
		CCAnimation* anim = [CCAnimation animationWithFrame:@"ship-anim" frameCount:5 delay:0.08f];
		
		// add the animation to the sprite (optional)
		//[sprite addAnimation:anim];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[self runAction:repeat];
	}
	return self;
}

// moved back to ShipEntity ... the enemies currently don't need it and it gets in the way when
// resetting enemy positions during spawn

// override setPosition to keep entitiy within screen bounds
-(void) setPosition:(CGPoint)pos
{
	// If the current position is (still) outside the screen no adjustments should be made!
	// This allows entities to move into the screen from outside.
	if (CGRectContainsRect([GameScene screenRect], [self boundingBox]))
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float halfWidth = self.contentSize.width * 0.5f;
		float halfHeight = self.contentSize.height * 0.5f;
		
		// Cap the position so the Ship's sprite stays on the screen
		if (pos.x < halfWidth)
		{
			pos.x = halfWidth;
		}
		else if (pos.x > (screenSize.width - halfWidth))
		{
			pos.x = screenSize.width - halfWidth;
		}
		
		if (pos.y < halfHeight)
		{
			pos.y = halfHeight;
		}
		else if (pos.y > (screenSize.height - halfHeight))
		{
			pos.y = screenSize.height - halfHeight;
		}
	}
	
	[super setPosition:pos];
}

@end
