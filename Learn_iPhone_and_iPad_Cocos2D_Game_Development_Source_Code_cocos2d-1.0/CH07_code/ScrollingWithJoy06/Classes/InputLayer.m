//
//  InputLayer.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "InputLayer.h"
#import "GameScene.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
@end


@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addFireButton];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	fireButton = [SneakyButton button];
	fireButton.isHoldable = YES;
	
	SneakyButtonSkinnedBase* skinFireButton = [SneakyButtonSkinnedBase skinnedButton];
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius, buttonRadius);
	skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"button-default.png"];
	skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"button-pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];
}

-(void) update:(ccTime)delta
{
	totalTime += delta;
	
	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.5f;
		
		GameScene* game = [GameScene sharedGameScene];
		[game shootBulletFromShip:[game defaultShip]];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
}

@end
