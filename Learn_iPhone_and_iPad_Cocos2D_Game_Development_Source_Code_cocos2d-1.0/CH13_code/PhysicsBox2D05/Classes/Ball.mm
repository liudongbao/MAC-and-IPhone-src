//
//  Ball.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"
#import "Helper.h"
#import "PinballTable.h"

@interface Ball (PrivateMethods)
-(void) createBallInWorld:(b2World*)world;
@end


@implementation Ball

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super init]))
	{
		[self createBallInWorld:world];
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
		
		[self scheduleUpdate];
	}
	return self;
}

+(id) ballWithWorld:(b2World*)world
{
	return [[[self alloc] initWithWorld:world] autorelease];
}

-(void) dealloc
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}

-(void) createBallInWorld:(b2World*)world
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
	CGPoint startPos = CGPointMake(screenSize.width - 15 + randomOffset, 80);
	
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = [Helper toMeters:startPos];
	bodyDef.angularDamping = 0.9f;
	
	NSString* spriteFrameName = @"ball.png";
	CCSprite* tempSprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
	
	b2CircleShape shape;
	float radiusInMeters = (tempSprite.contentSize.width / PTM_RATIO) * 0.5f;
	shape.m_radius = radiusInMeters;
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 0.8f;
	fixtureDef.friction = 0.7f;
	fixtureDef.restitution = 0.3f;
	
	[super createBodyInWorld:world bodyDef:&bodyDef fixtureDef:&fixtureDef spriteFrameName:spriteFrameName];
	
	sprite.color = ccRED;
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = body->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFinger = fingerPos - bodyPos;
	b2Vec2 force = 10.0f * bodyToFinger;
	
	// "Real" gravity falls off by the square over distance. Feel free to try it this way:
	/*
	float distance = bodyToFinger.Normalize();
	float distanceSquared = distance * distance;
	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFinger;
	*/
	
	body->ApplyForce(force, body->GetWorldCenter());
}

-(void) update:(ccTime)delta
{
	if (moveToFinger == YES)
	{
		// disabled: not needed anymore
		//[self applyForceTowardsFinger];
	}
	
	if (sprite.position.y < -(sprite.contentSize.height * 10))
	{
		// create a new ball and remove the old one
		[self createBallInWorld:body->GetWorld()];
	}
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	moveToFinger = YES;
	fingerLocation = [Helper locationFromTouch:touch];
	return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	fingerLocation = [Helper locationFromTouch:touch];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	moveToFinger = NO;
}


@end
