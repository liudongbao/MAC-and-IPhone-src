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
#import "GameScene.h"
#import "Ship.h"

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
	skinFireButton.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-idle.png"];
	skinFireButton.pressSprite = [CCSprite spriteWithSpriteFrameName:@"fire-button-pressed.png"];
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
	skinStick.backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-back.png"];
	skinStick.backgroundSprite.color = ccYELLOW;
	skinStick.thumbSprite = [CCSprite spriteWithSpriteFrameName:@"joystick-stick.png"];
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
		[game shootBulletFromShip:[game defaultShip]];
	}
	
	// Allow faster shooting by quickly tapping the fire button.
	if (fireButton.active == NO)
	{
		nextShotTime = 0;
	}
	
	// Moving the ship with the thumbstick.
	GameScene* game = [GameScene sharedGameScene];
	Ship* ship = [game defaultShip];
	
	CGPoint velocity = ccpMult(joystick.velocity, 7000 * delta);
	if (velocity.x != 0 && velocity.y != 0)
	{
		ship.position = CGPointMake(ship.position.x + velocity.x * delta, ship.position.y + velocity.y * delta);
	}
}

@end
