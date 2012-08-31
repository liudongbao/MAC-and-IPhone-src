/*
 *  ContactListener.mm
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 */

#import "ContactListener.h"
#import "BodyNode.h"
#import "Plunger.h"
#import "Ball.h"

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	BodyNode* bodyNodeA = (BodyNode*)bodyA->GetUserData();
	BodyNode* bodyNodeB = (BodyNode*)bodyB->GetUserData();
	
	// start plunger on contact
	if ([bodyNodeA isKindOfClass:[Plunger class]] && [bodyNodeB isKindOfClass:[Ball class]])
	{
		Plunger* plunger = (Plunger*)bodyNodeA;
		plunger.doPlunge = YES;
	}
	else if ([bodyNodeB isKindOfClass:[Plunger class]] && [bodyNodeA isKindOfClass:[Ball class]])
	{
		Plunger* plunger = (Plunger*)bodyNodeB;
		plunger.doPlunge = YES;
	}
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
}

void ContactListener::EndContact(b2Contact* contact)
{
}
