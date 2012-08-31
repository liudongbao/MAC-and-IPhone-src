//
//  BulletCache.m
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

#import "BulletCache.h"
#import "Bullet.h"

@implementation BulletCache

-(id) init
{
	if ((self = [super init]))
	{
		// get any bullet image from the Texture Atlas we're using
		CCSpriteFrame* bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bullet.png"];
		// use the bullet's texture (which will be the Texture Atlas used by the game)
		batch = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture];
		[self addChild:batch];
		
		// Create a number of bullets up front and re-use them whenever necessary.
		for (int i = 0; i < 200; i++)
		{
			Bullet* bullet = [Bullet bullet];
			bullet.visible = NO;
			[batch addChild:bullet];
		}
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName
{
	CCArray* bullets = [batch children];
	CCNode* node = [bullets objectAtIndex:nextInactiveBullet];
	NSAssert([node isKindOfClass:[Bullet class]], @"not a Bullet!");
	
	Bullet* bullet = (Bullet*)node;
	[bullet shootBulletAt:startPosition velocity:velocity frameName:frameName];
	
	nextInactiveBullet++;
	if (nextInactiveBullet >= [bullets count])
	{
		nextInactiveBullet = 0;
	}
}

@end
