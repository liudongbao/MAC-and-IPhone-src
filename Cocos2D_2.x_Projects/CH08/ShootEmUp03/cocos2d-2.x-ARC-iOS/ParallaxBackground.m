//
//  ParallaxBackground.m
//  ScrollingWithJoy
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

#import "ParallaxBackground.h"


static BOOL fixFlickeringLine = YES;


@implementation ParallaxBackground

-(id) init
{
	if ((self = [super init]))
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		// Get the game's texture atlas texture by adding it. Since it's added already it will simply return 
		// the CCTexture2D associated with the texture atlas.
		CCTexture2D* gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:@"game-art.pvr.ccz"];
		
		// Create the background spritebatch
		spriteBatch = [CCSpriteBatchNode batchNodeWithTexture:gameArtTexture];
		[self addChild:spriteBatch];
		
		numStripes = 7;
		
		// Add the 6 different layer objects and position them on the screen
		for (int i = 0; i < numStripes; i++)
		{
			NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
			CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
			sprite.anchorPoint = CGPointMake(0, 0.5f);
			sprite.position = CGPointMake(0, screenSize.height / 2);
			[spriteBatch addChild:sprite z:i];
		}
		
		// Add 7 more stripes, flip them and position them next to their neighbor stripe
		for (int i = 0; i < numStripes; i++)
		{
			NSString* frameName = [NSString stringWithFormat:@"bg%i.png", i];
			CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:frameName];
			
			// Position the new sprite one screen width to the right
			sprite.anchorPoint = CGPointMake(0, 0.5f);
			
			if (fixFlickeringLine)
			{
				// this is part of the flicker fix, subtracting 1 from screen width to have stripes overlap
				sprite.position = CGPointMake(screenSize.width - 1, screenSize.height / 2);
			}
			else 
			{
				sprite.position = CGPointMake(screenSize.width, screenSize.height / 2);
			}
			
			// Flip the sprite so that it aligns perfectly with its neighbor
			sprite.flipX = YES;
			
			// Add the sprite using the same tag offset by numStripes
			[spriteBatch addChild:sprite z:i tag:i + numStripes];
		}
		
		// Initialize the array that contains the scroll factors for individual stripes.
		speedFactors = [NSMutableArray arrayWithCapacity:numStripes];
		[speedFactors addObject:[NSNumber numberWithFloat:0.3f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.5f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.5f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.8f]];
		[speedFactors addObject:[NSNumber numberWithFloat:0.8f]];
		[speedFactors addObject:[NSNumber numberWithFloat:1.2f]];
		[speedFactors addObject:[NSNumber numberWithFloat:1.2f]];
		NSAssert(speedFactors.count == (NSUInteger)numStripes, @"speedFactors count does not match numStripes!");
		
		scrollSpeed = 1.0f;
		[self scheduleUpdate];
		
		BOOL showRepeatTextureTest = NO;
		if (showRepeatTextureTest)
		{
			CGRect repeatRect = CGRectMake(0, 0, 8000, 8000);
			CCSprite* sprite = [CCSprite spriteWithFile:@"iTunesArtwork" rect:repeatRect];
			sprite.position = CGPointMake(200, 200);
			sprite.scale = 0.1f;
			sprite.rotation = 30.0f;
			ccTexParams params = 
			{
				GL_LINEAR, // texture minifying function
				GL_LINEAR, // texture magnification function
				GL_REPEAT, // how texture should wrap along X coordinates
				GL_REPEAT  // how texture should wrap along Y coordinates
			};
			[sprite.texture setTexParameters:&params];
			[self addChild:sprite];
			
		}
	}
	return self;
}

-(void) update:(ccTime)delta
{
	for (CCSprite* sprite in spriteBatch.children)
	{
		NSNumber* factor = [speedFactors objectAtIndex:sprite.zOrder];
		
		CGPoint pos = sprite.position;
		pos.x -= (scrollSpeed * factor.floatValue) * (delta * 50);
		
		// Reposition stripes when they're out of bounds
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		if (pos.x < -screenSize.width)
		{
			if (fixFlickeringLine)
			{
				// this fixes the flickering line
				pos.x += (screenSize.width * 2) - 2;
			}
			else
			{
				pos.x += screenSize.width * 2;
			}
		}
		
		sprite.position = pos;
	}
}

@end
