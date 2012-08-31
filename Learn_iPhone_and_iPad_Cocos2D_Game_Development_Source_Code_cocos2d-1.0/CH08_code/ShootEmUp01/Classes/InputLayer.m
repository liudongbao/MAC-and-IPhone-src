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
-(void) addJoystick;
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
	skinFireButton.position = CGPointMake(screenSize.width - buttonRadius * 1.5f, buttonRadius * 1.5f);
	skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"button-default.png"];
	skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"button-pressed.png"];
	skinFireButton.button = fireButton;
	[self addChild:skinFireButton];
}

-(void) addJoystick
{
	float stickRadius = 50;

	joystick = [SneakyJoystick joystickWithRect:CGRectMake(0, 0, stickRadius, stickRadius)];
	joystick.autoCenter = YES;
	
	// Now with fewer directions
	joystick.isDPad = YES;
	joystick.numberOfDirections = 8;
	
	SneakyJoystickSkinnedBase* skinStick = [SneakyJoystickSkinnedBase skinnedJoystick];
	skinStick.position = CGPointMake(stickRadius * 1.5f, stickRadius * 1.5f);
	skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"button-disabled.png"];
	skinStick.backgroundSprite.color = ccMAGENTA;
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"button-disabled.png"];
	skinStick.thumbSprite.scale = 0.5f;
	skinStick.joystick = joystick;
	[self addChild:skinStick];
}

-(void) update:(ccTime)delta
{
	totalTime += delta;

	// Continuous fire
	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.5f;

		GameScene* game = [GameScene sharedGameScene];
		Ship* ship = [game defaultShip];
		BulletCache* bulletCache = [game bulletCache];

		// Set the position, velocity and spriteframe before shooting
		CGPoint shotPos = CGPointMake(ship.position.x + [ship contentSize].width * 0.5f, ship.position.y);
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		CGPoint velocity = CGPointMake(1, spread);
		[bulletCache shootBulletAt:shotPos velocity:velocity frameName:@"bullet.png"];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
	
	// Moving the ship with the thumbstick.
	GameScene* game = [GameScene sharedGameScene];
	Ship* ship = [game defaultShip];
	
	CGPoint velocity = ccpMult(joystick.velocity, 200);
	if (velocity.x != 0 && velocity.y != 0)
	{
		ship.position = CGPointMake(ship.position.x + velocity.x * delta, ship.position.y + velocity.y * delta);
	}
}

@end
