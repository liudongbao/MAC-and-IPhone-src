//
//  Plunger.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Plunger.h"
#import "ContactListener.h"

@implementation Plunger

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"plunger" inWorld:world]))
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint plungerPos = CGPointMake(screenSize.width - 13, -32);
		
		physicsBody->SetTransform([Helper toMeters:plungerPos], 0);
        physicsBody->SetType(b2_dynamicBody);

		[self attachPlunger];
	}
	return self;
}

+(id) plungerWithWorld:(b2World*)world
{
	return [[self alloc] initWithWorld:world];
}

-(void) attachPlunger
{
	// create an invisible static body to attach joint to
	b2BodyDef bodyDef;
	bodyDef.position = physicsBody->GetWorldCenter();
	b2Body* staticBody = physicsBody->GetWorld()->CreateBody(&bodyDef);
	
	// Create a prismatic joint to make plunger go up/down
	b2PrismaticJointDef jointDef;
	b2Vec2 worldAxis(0.0f, 1.0f);
	jointDef.Initialize(staticBody, physicsBody, physicsBody->GetWorldCenter(), worldAxis);
	jointDef.lowerTranslation = 0.0f;
	jointDef.upperTranslation = 0.35f;
	jointDef.enableLimit = true;
	jointDef.maxMotorForce = 100.0f;
	jointDef.motorSpeed = 50.0f;
	jointDef.enableMotor = false;
	
	joint = (b2PrismaticJoint*)physicsBody->GetWorld()->CreateJoint(&jointDef);
}
 
-(void) endPlunge:(ccTime)delta
{
    // stop the motor
	joint->EnableMotor(NO);
}

-(void) beginContactWithBall:(Contact*)contact
{
    // start the motor
    joint->EnableMotor(YES);

    // schedule motor to come back, unschedule in case the plunger is hit repeatedly within a short time
    [self scheduleOnce:@selector(endPlunge:) delay:0.5f];
}

@end
