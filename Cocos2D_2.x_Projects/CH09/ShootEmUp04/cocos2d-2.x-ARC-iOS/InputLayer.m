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
#import "BulletCache.h"

#import "SimpleAudioEngine.h"

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
	totalTime += delta;

	GameLayer* game = [GameLayer sharedGameLayer];
	Ship* ship = game.defaultShip;
	BulletCache* bulletCache = game.bulletCache;
	
	if (fireButton.active && totalTime > nextShotTime)
	{
		nextShotTime = totalTime + 0.4f;
		
		// Set the position, velocity and spriteframe before shooting
		CGPoint shotPos = CGPointMake(ship.position.x + 45, ship.position.y - 19);
		
		float spread = (CCRANDOM_0_1() - 0.5f) * 0.5f;
		CGPoint velocity = CGPointMake(200, spread * 50);
		[bulletCache shootBulletFrom:shotPos velocity:velocity frameName:@"bullet.png" isPlayerBullet:YES];

		float pitch = CCRANDOM_0_1() * 0.2f + 0.9f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot1.wav" pitch:pitch pan:0.0f gain:1.0f];
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
