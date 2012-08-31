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

static CGRect screenRect;

-(id) initWithBulletImage
{
	// Uses the Texture Atlas now.
	if ((self = [super initWithSpriteFrameName:@"bullet.png"]))
	{
		// make sure to initialize the screen rect only once
		if (CGRectIsEmpty(screenRect))
		{
			CGSize screenSize = [[CCDirector sharedDirector] winSize];
			screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
		}
	}
	
	return self;
}

-(void) dealloc
{
	
	[super dealloc];
}

// Re-Uses the bullet
-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName
{
	self.velocity = vel;
	self.position = startPosition;
	self.visible = YES;

	// change the bullet's texture by setting a different SpriteFrame to be displayed
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
	[self setDisplayFrame:frame];
	
	[self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
	self.position = ccpAdd(self.position, velocity);
	
	// When the bullet leaves the screen, make it invisible
	if (CGRectIntersectsRect([self boundingBox], screenRect) == NO)
	{
		self.visible = NO;
		[self unscheduleAllSelectors];
	}
}

@end
