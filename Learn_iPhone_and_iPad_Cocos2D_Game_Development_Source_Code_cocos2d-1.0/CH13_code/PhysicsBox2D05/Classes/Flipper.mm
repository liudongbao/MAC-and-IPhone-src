//
//  Flipper.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Flipper.h"
#import "PinballTable.h"

@interface Flipper (PrivateMethods)
-(void) attachFlipperAt:(b2Vec2)pos;
@end


@implementation Flipper

-(id) initWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType
{
	if ((self = [super init]))
	{
		type = flipperType;
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		CGPoint flipperPos = CGPointMake(screenSize.width / 2 - 48, 55);
		if (type == FlipperRight)
		{
			flipperPos = CGPointMake(screenSize.width / 2 + 40, 55);
		}
		
		// Create a body definition, it's a static body (bumpers don't move)
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position = [Helper toMeters:flipperPos];
		
		// Define the dynamic body fixture.
		b2FixtureDef fixtureDef;
		fixtureDef.density = 1.0f;
		fixtureDef.friction = 0.99f;
		fixtureDef.restitution = 0.1f;

		b2PolygonShape shape;
		b2Vec2 revolutePoint;
		b2Vec2 revolutePointOffset = b2Vec2(0.5f, 0.0f);
		
		if (type == FlipperLeft)
		{
			int numVertices = 4;
			b2Vec2 vertices[] = {
				b2Vec2(-20.5f / PTM_RATIO, -1.7f / PTM_RATIO),
				b2Vec2(25.0f / PTM_RATIO, -25.5f / PTM_RATIO),
				b2Vec2(29.5f / PTM_RATIO, -23.7f / PTM_RATIO),
				b2Vec2(-10.2f / PTM_RATIO, 12.5f / PTM_RATIO)
			};
			
			shape.Set(vertices, numVertices);
			revolutePoint = bodyDef.position - revolutePointOffset;
		}
		else
		{
			int numVertices = 4;
			b2Vec2 vertices[] = {
				b2Vec2(11.0f / PTM_RATIO, 12.5f / PTM_RATIO),
				b2Vec2(-29.5f / PTM_RATIO, -23.5f / PTM_RATIO),
				b2Vec2(-23.2f / PTM_RATIO, -25.5f / PTM_RATIO),
				b2Vec2(19.7f / PTM_RATIO, -1.7f / PTM_RATIO)
			};
			
			shape.Set(vertices, numVertices);
			revolutePoint = bodyDef.position + revolutePointOffset;
		}
	
		fixtureDef.shape = &shape;
		
		[super createBodyInWorld:world bodyDef:&bodyDef fixtureDef:&fixtureDef spriteFrameName:@"flipper-left.png"];

		if (type == FlipperRight)
		{
			sprite.flipX = YES;
		}
		
		// Attach the flipper to a static body with a revolute joint, so it can move up/down
		[self attachFlipperAt:revolutePoint];

		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	}
	return self;
}

+(id) flipperWithWorld:(b2World*)world flipperType:(EFlipperType)flipperType
{
	return [[[self alloc] initWithWorld:world flipperType:flipperType] autorelease];
}

-(void) dealloc
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super dealloc];
}

-(void) attachFlipperAt:(b2Vec2)pos
{
	// create an invisible static body to attach to
	b2BodyDef bodyDef;
	bodyDef.position = pos;
	b2Body* staticBody = body->GetWorld()->CreateBody(&bodyDef);
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(staticBody, body, staticBody->GetWorldCenter());
	jointDef.lowerAngle = 0.0f;
	jointDef.upperAngle = CC_DEGREES_TO_RADIANS(70);
	jointDef.enableLimit = true;
	jointDef.maxMotorTorque = 30.0f;
	jointDef.motorSpeed = -20.0f;
	jointDef.enableMotor = true;

	if (type == FlipperRight)
	{
		jointDef.motorSpeed *= -1;
		jointDef.lowerAngle = -jointDef.upperAngle;
		jointDef.upperAngle = 0.0f;
	}
	
	joint = (b2RevoluteJoint*)body->GetWorld()->CreateJoint(&jointDef);
}

-(void) reverseMotor
{
	joint->SetMotorSpeed(joint->GetMotorSpeed() * -1);
}

-(bool) isTouchForMe:(CGPoint)location
{
	if (type == FlipperLeft && location.x < [Helper screenCenter].x)
	{
		return YES;
	}
	else if (type == FlipperRight && location.x > [Helper screenCenter].x)
	{
		return YES;
	}
	
	return NO;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL touchHandled = NO;
	
	CGPoint location = [Helper locationFromTouch:touch];
	if ([self isTouchForMe:location])
	{
		touchHandled = YES;
		[self reverseMotor];
	}
	
	return touchHandled;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [Helper locationFromTouch:touch];
	if ([self isTouchForMe:location])
	{
		[self reverseMotor];
	}
}

@end
