//
//  TargetTouchScene.m
//  G05
//
//  Created by zhu yi on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TargetTouchScene.h"
#import "KillingLight.h"


@implementation TargetTouchScene


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TargetTouchScene *layer = [TargetTouchScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"killer.png" capacity:10];
		[self addChild:mgr z:0];
		
		KillingLight *sprite = [KillingLight KillingLightWithRect:CGRectMake(8 * 32,0,32,134) spriteManager:mgr];
		[mgr addChild:sprite z:1 tag:5];
		
		sprite.position = ccp(240, 160);
		
		CCAnimation *animation = [CCAnimation animationWithName:@"killing" delay:0.05f];
		for(int i=0;i<9;i++) {
			[animation addFrameWithTexture:mgr.texture rect:CGRectMake((8 - i)*32, 0, 32, 134) ];
		}				
		id action = [CCAnimate actionWithAnimation: animation];

		CCAnimation *r_animation = [CCAnimation animationWithName:@"r_killing" delay:0.05f];
		for(int i=0;i<9;i++) {
			[r_animation addFrameWithTexture:mgr.texture rect:CGRectMake(i*32, 0, 32, 134) ];
		}				
		id r_action = [CCAnimate actionWithAnimation: r_animation];

		id ac = [CCSequence actions:[CCDelayTime actionWithDuration:0.3], action, r_action, nil];
		
		[sprite runAction:[CCRepeatForever actionWithAction:ac]];	
		
	}
	return self;
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
