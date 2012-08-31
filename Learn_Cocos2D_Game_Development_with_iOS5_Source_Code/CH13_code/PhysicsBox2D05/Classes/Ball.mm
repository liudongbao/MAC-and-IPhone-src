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
#import "b2Math.h"

#import "SimpleAudioEngine.h"

@interface Ball (PrivateMethods)
-(void) createBallInWorld:(b2World*)world;
-(void) setBallStartPosition;
@end


@implementation Ball

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"ball" inWord:world]))
	{
        // set the parameters
        body->SetType(b2_dynamicBody);
        body->SetAngularDamping(0.9f);

        // enable continuous collision detection
        body->SetBullet(true);

        // set random starting point
        [self setBallStartPosition];

        // enable handling touches
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];

        // schedule updates
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

-(void) setBallStartPosition
{
    // set the ball's position
    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGPoint startPos = CGPointMake(305 + randomOffset, 80);
    
    body->SetTransform([Helper toMeters:startPos], 0.0f);    
    body->SetLinearVelocity(b2Vec2_zero);
    body->SetAngularVelocity(0.0f);
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = body->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFingerDirection = fingerPos - bodyPos;
	b2Vec2 force = 10.0f * bodyToFingerDirection;
	
	// "Real" gravity falls off by the square over distance. Feel free to try it this way:
	/*
	float distance = bodyToFingerDirection.Length();
	bodyToFingerDirection.Normalize();
	float distanceSquared = distance * distance;
	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFingerDirection;
	*/
	
	body->ApplyForce(force, body->GetWorldCenter());
}

-(void) update:(ccTime)delta
{
	if (moveToFinger == YES)
	{
		// disabled: no longer needed
		// [self applyForceTowardsFinger];
	}
	
	if (self.position.y < -(self.contentSize.height * 10))
	{
		// restart at a random position
		[self setBallStartPosition];
	}

    // limit speed of the ball
    const float32 maxSpeed = 6.0f;
    b2Vec2 velocity = body->GetLinearVelocity();
    float32 speed = velocity.Length();
    if (speed > maxSpeed)
    {
        body->SetLinearVelocity((maxSpeed / speed) * velocity);
    }

    // reset rotation of the ball to keep
    // highlight and shadow in the same place
    body->SetTransform(body->GetWorldCenter(), 0.0f);
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

-(void) playSound
{
	float pitch = 0.9f + CCRANDOM_0_1() * 0.2f;
	float gain = 1.0f + CCRANDOM_0_1() * 0.3f;
	[[SimpleAudioEngine sharedEngine] playEffect:@"bumper.wav" pitch:pitch pan:0.0f gain:gain];

}

-(void) endContactWithBumper:(Contact*)contact
{
	[self playSound];
}

-(void) endContactWithPlunger:(Contact*)contact
{
	[self playSound];
}

@end
