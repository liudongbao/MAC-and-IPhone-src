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
#import "GameScene.h"

@interface Bullet (PrivateMethods)
-(id) initWithBulletImage;
@end


@implementation Bullet

@synthesize velocity;
@synthesize isPlayerBullet;

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

// Re-Uses the bullet
-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName isPlayerBullet:(bool)playerBullet
{
	self.velocity = vel;
	self.position = startPosition;
	self.visible = YES;
	self.isPlayerBullet = playerBullet;

	// change the bullet's texture by setting a different SpriteFrame to be displayed
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
	[self setDisplayFrame:frame];
	
	[self unscheduleUpdate];
	[self scheduleUpdate];
	
	CCRotateBy* rotate = [CCRotateBy actionWithDuration:1 angle:-360];
	CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotate];
	[self runAction:repeat];
}

-(void) update:(ccTime)delta
{
	self.position = ccpAdd(self.position, ccpMult(velocity, delta));
	
	// When the bullet leaves the screen, make it invisible
	if (CGRectIntersectsRect([self boundingBox], [GameScene screenRect]) == NO)
	{
		self.visible = NO;
		[self stopAllActions];
		[self unscheduleUpdate];
	}
}

@end
