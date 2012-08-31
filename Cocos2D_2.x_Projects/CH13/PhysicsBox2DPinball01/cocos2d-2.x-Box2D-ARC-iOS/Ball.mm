//
//  Ball.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Ball.h"
#import "SimpleAudioEngine.h"
#import "ContactListener.h"

@implementation Ball
-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"ball" inWorld:world]))
	{
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        physicsBody->SetAngularDamping(0.9f);

        // set random starting point
        [self setBallStartPosition];

        // enable handling touches
		[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];

        // schedule updates
		[self scheduleUpdate];
	}
	return self;
}

+(id) ballWithWorld:(b2World*)world
{
	return [[self alloc] initWithWorld:world];
}

-(void) cleanup
{
	[super cleanup];
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

-(void) setBallStartPosition
{
    // set the ball's position
    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGPoint startPos = CGPointMake(305 + randomOffset, 80);
    
    physicsBody->SetTransform([Helper toMeters:startPos], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = physicsBody->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFingerDirection = fingerPos - bodyPos;
	bodyToFingerDirection.Normalize();
	
	b2Vec2 force = 2.0f * bodyToFingerDirection;
	
	// "Real" gravity falls off by the square over distance. Uncomment this code to see the effect:
	/*
	float distance = bodyToFingerDirection.Length();
	bodyToFingerDirection.Normalize();
	float distanceSquared = distance * distance;
	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFingerDirection;
	*/
	
	physicsBody->ApplyForce(force, physicsBody->GetWorldCenter());
}

-(void) update:(ccTime)delta
{
	if (moveToFinger == YES)
	{
		//[self applyForceTowardsFinger];
	}
	
	//CCLOG(@"posY = %.1f", self.position.y);
	if (self.position.y < -(self.contentSize.height * 10))
	{
		// restart at a random position
		[self setBallStartPosition];
	}

    // limit speed of the ball
    const float32 maxSpeed = 8.0f;
    b2Vec2 velocity = physicsBody->GetLinearVelocity();
    float32 speed = velocity.Length();
    if (speed > maxSpeed)
    {
		velocity.Normalize();
		physicsBody->SetLinearVelocity(maxSpeed * velocity);
		//CCLOG(@"reset speed %f to %f", speed, (maxSpeed * velocity).Length());
    }

    // reset rotation of the ball to keep
    // highlight and shadow in the same place
    physicsBody->SetTransform(physicsBody->GetWorldCenter(), 0.0f);
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
