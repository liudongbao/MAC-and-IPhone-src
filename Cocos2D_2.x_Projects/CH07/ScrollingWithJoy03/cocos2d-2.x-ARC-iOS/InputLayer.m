//
//  InputLayer.m
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

#import "InputLayer.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
@end

@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addFireButton];
		[self addJoystick];

		[self scheduleUpdate];
	}
	return self;
}

-(void) addFireButton
{
	float buttonRadius = 50;
	CGSize screenSize = [CCDirector sharedDirector].winSize;

	BOOL useSkinnedButton = YES;
	if (useSkinnedButton)
	{
		CCSprite* idle = [CCSprite spriteWithSpriteFrameName:@"fire-button-idle.png"];
		CCSprite* press = [CCSprite spriteWithSpriteFrameName:@"fire-button-pressed.png"];

		fireButton = [[SneakyButton alloc] initWithRect:CGRectZero];
		fireButton.isHoldable = YES;
		
		SneakyButtonSkinnedBase* skinFireButton = [[SneakyButtonSkinnedBase alloc] init];
		skinFireButton.button = fireButton;
		skinFireButton.defaultSprite = idle;
		skinFireButton.pressSprite = press;
		skinFireButton.position = CGPointMake(screenSize.width - buttonRadius, buttonRadius);
		[self addChild:skinFireButton];
	}
	else 
	{
		fireButton = [[SneakyButton alloc] initWithRect:CGRectZero];
		fireButton.radius = buttonRadius;
		fireButton.position = CGPointMake(screenSize.width - buttonRadius, buttonRadius);
		[self addChild:fireButton];
	}
}

-(void) addJoystick
{
	float stickRadius = 50;
	
	joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	joystick.hasDeadzone = YES;
	joystick.deadRadius = 10;

	BOOL joystickIsDPad = NO;
	if (joystickIsDPad)
	{
		joystick.isDPad = YES;
		joystick.numberOfDirections = 8;
	}
	
	CCSprite* back = [CCSprite spriteWithSpriteFrameName:@"joystick-back.png"];
	CCSprite* thumb = [CCSprite spriteWithSpriteFrameName:@"joystick-stick.png"];
	
	SneakyJoystickSkinnedBase* skinStick = [[SneakyJoystickSkinnedBase alloc] init];
	skinStick.joystick = joystick;
	skinStick.backgroundSprite.color = ccYELLOW;
	skinStick.backgroundSprite = back;
	skinStick.thumbSprite = thumb;
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{
	/*
	if (fireButton.active)
	{
		CCLOG(@"FIRE!!!");
	}
	*/
	
	totalTime += delta;

	GameLayer* game = [GameLayer sharedGameLayer];
	Ship* ship = [game defaultShip];

	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.5f;
		[game shootBulletFromShip:ship];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}

	CGPoint velocity = ccpMult(joystick.velocity, 7000 * delta);
	ship.position = CGPointMake(ship.position.x + velocity.x * delta, 
								ship.position.y + velocity.y * delta);
}

@end
