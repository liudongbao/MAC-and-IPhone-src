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
		// load the ship's animation frames as textures and create a sprite frame
		NSMutableArray* frames = [NSMutableArray arrayWithCapacity:5];
		for (int i = 0; i < 5; i++)
		{
			NSString* file = [NSString stringWithFormat:@"ship-anim%i.png", i];
			CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:file];
			CGSize texSize = texture.contentSize;
			CGRect texRect = CGRectMake(0, 0, texSize.width, texSize.height);
			CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:texture rect:texRect];
			[frames addObject:frame];
		}
		
		// create an animation object from all the sprite animation frames
		CCAnimation* anim = [CCAnimation animationWithFrames:frames delay:0.08f];
		
		// add the animation to the sprite
		//[self addAnimation:anim];
		
		// run the animation by using the CCAnimate action
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[self runAction:repeat];
		
		
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
