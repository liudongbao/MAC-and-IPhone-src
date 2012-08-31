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
#import "Constants.h"

void ContactListener::BeginContact(b2Contact* contact)
{
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
