/*
 *  ContactListener.mm
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 */

#import "ContactListener.h"
#import "cocos2d.h"
#import "PhysicsSprite.h"

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	PhysicsSprite* spriteA = (__bridge PhysicsSprite*)bodyA->GetUserData();
	PhysicsSprite* spriteB = (__bridge PhysicsSprite*)bodyB->GetUserData();
	
	if (spriteA != NULL && spriteB != NULL)
	{
		spriteA.color = ccMAGENTA;
		spriteB.color = ccMAGENTA;
	}
}

void ContactListener::EndContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	PhysicsSprite* spriteA = (__bridge PhysicsSprite*)bodyA->GetUserData();
	PhysicsSprite* spriteB = (__bridge PhysicsSprite*)bodyB->GetUserData();
	
	if (spriteA != NULL && spriteB != NULL)
	{
		spriteA.color = ccWHITE;
		spriteB.color = ccWHITE;
	}
}
