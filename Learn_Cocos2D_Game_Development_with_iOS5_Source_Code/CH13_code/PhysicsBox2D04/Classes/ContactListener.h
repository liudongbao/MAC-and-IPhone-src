/*
 *  ContactListener.h
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 *  Enhanced to use PhysicsEditor shapes and retina display
 *  by Andreas Loew / http://www.physicseditor.de
 *
 */

#import "Box2D.h"
#import "b2WorldCallbacks.h"

class ContactListener : public b2ContactListener
{
private:
	void BeginContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	void EndContact(b2Contact* contact);
};