//
//  Plunger.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Plunger.h"
#import "PinballTable.h"

@interface Plunger (PrivateMethods)
-(void) attachPlunger;
@end


@implementation Plunger

@synthesize doPlunge;

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super init]))
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		CGPoint plungerPos = CGPointMake(screenSize.width - 13, 32);
		
		// Create a body definition
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position = [Helper toMeters:plungerPos];
		
		b2PolygonShape shape;
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(10.5f / PTM_RATIO, 10.6f / PTM_RATIO),
			b2Vec2(11.8f / PTM_RATIO, 18.1f / PTM_RATIO),
			b2Vec2(-11.9f / PTM_RATIO, 18.3f / PTM_RATIO),
			b2Vec2(-10.5f / PTM_RATIO, 10.8f / PTM_RATIO)
		};
		shape.Set(vertices, num);
		
		// Define the dynamic body fixture.
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &shape;
		fixtureDef.density = 1.0f;
		fixtureDef.friction = 0.99f;
		fixtureDef.restitution = 0.01f;
		
		[super createBodyInWorld:world bodyDef:&bodyDef fixtureDef:&fixtureDef spriteFrameName:@"plunger.png"];
		
		sprite.position = plungerPos;

		[self attachPlunger];
		
		[self scheduleUpdate];
	}
	return self;
}

+(id) plungerWithWorld:(b2World*)world
{
	return [[[self alloc] initWithWorld:world] autorelease];
}

-(void) attachPlunger
{
	// create an invisible static body to attach joint to
	b2BodyDef bodyDef;
	bodyDef.position = body->GetWorldCenter();
	b2Body* staticBody = body->GetWorld()->CreateBody(&bodyDef);
	
	// Create a prismatic joint to make plunger go up/down
	b2PrismaticJointDef jointDef;
	b2Vec2 worldAxis(0.0f, 1.0f);
	jointDef.Initialize(staticBody, body, body->GetWorldCenter(), worldAxis);
	jointDef.lowerTranslation = 0.0f;
	jointDef.upperTranslation = 0.75f;
	jointDef.enableLimit = true;
	jointDef.maxMotorForce = 60.0f;
	jointDef.motorSpeed = 20.0f;
	jointDef.enableMotor = false;
	
	joint = (b2PrismaticJoint*)body->GetWorld()->CreateJoint(&jointDef);
}

-(void) endPlunge:(ccTime)delta
{
	[self unschedule:_cmd];
	joint->EnableMotor(NO);
}

-(void) update:(ccTime)delta
{
	if (doPlunge == YES)
	{
		doPlunge = NO;
		joint->EnableMotor(YES);

		// schedule motor to come back, unschedule in case the plunger is hit repeatedly within a short time
		[self unschedule:_cmd];
		[self schedule:@selector(endPlunge:) interval:0.5f];
	}
}

@end
