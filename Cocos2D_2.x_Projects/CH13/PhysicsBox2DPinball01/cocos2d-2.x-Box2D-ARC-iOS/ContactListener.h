/*
 *  ContactListener.h
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 */

#import "Box2D.h"

@interface Contact : NSObject
{
@private
    NSObject* otherObject;
    b2Fixture* ownFixture;
    b2Fixture* otherFixture;
    b2Contact* b2contact;
}

-(id) initWithObject:(NSObject*)otherObject_
		otherFixture:(b2Fixture*)otherFixture_
		  ownFixture:(b2Fixture*)ownFixture_
		   b2Contact:(b2Contact*)b2contact_;
@end


class ContactListener : public b2ContactListener
{
private:
	void BeginContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	void EndContact(b2Contact* contact);

    void notifyObjects(b2Contact* contact, NSString* contactType);
    void notifyAB(b2Contact* contact,
				  NSString* contactType,
				  b2Fixture* fixtureA,
				  NSObject* objA,
				  b2Fixture* fixtureB,
				  NSObject* objB);
};