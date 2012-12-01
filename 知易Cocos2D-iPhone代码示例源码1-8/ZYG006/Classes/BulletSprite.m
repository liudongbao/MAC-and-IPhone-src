//
//  BulletSprite.m
//  T06
//
//  Created by ZhuYi on 10/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BulletSprite.h"
#import "GameLayer.h"

@implementation BulletSprite

+ (id) BulletWithinLayer:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;

	BulletSprite *sprite = [BulletSprite spriteWithFile:@"bullet.PNG" rect:CGRectMake(0, 0, 16, 16)];
	[ly.gameWorld addChild:sprite z:100];

	[sprite setVisible:NO];
	[sprite SetGamelayer:layer];
	
	return sprite;
}

- (void)SetGamelayer:(CCLayer *)layer
{
	gLayer = layer;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
