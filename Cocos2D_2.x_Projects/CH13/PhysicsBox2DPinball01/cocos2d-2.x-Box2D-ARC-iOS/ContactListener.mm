/*
 *  ContactListener.mm
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 */

#import "ContactListener.h"

@implementation Contact
-(id) initWithObject:(NSObject*)otherObject_
		otherFixture:(b2Fixture*)otherFixture_
		  ownFixture:(b2Fixture*)ownFixture_
		   b2Contact:(b2Contact*)b2contact_
{
	self = [super init];
    if (self)
    {
        otherObject = otherObject_;
        otherFixture = otherFixture_;
        ownFixture = ownFixture_;
        b2contact = b2contact_;
    }
    return self;
}
@end


// notify the listener
void ContactListener::notifyAB(b2Contact* contact, 
							   NSString* contactType, 
							   b2Fixture* fixture,
							   NSObject* obj, 
							   b2Fixture* otherFixture, 
							   NSObject* otherObj)
{
	NSString* format = @"%@ContactWith%@:";
	NSString* otherClassName = NSStringFromClass([otherObj class]);
	NSString* selectorString = [NSString stringWithFormat:format, contactType, otherClassName];
	//CCLOG(@"notifyAB selector: %@", selectorString);
    SEL contactSelector = NSSelectorFromString(selectorString);
	
    if ([obj respondsToSelector:contactSelector])
    {
		CCLOG(@"notifyAB performs selector: %@", selectorString);
		
        Contact* contactInfo = [[Contact alloc] initWithObject:otherObj
												  otherFixture:otherFixture
													ownFixture:fixture
													 b2Contact:contact];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [obj performSelector:contactSelector withObject:contactInfo];
#pragma clang diagnostic pop
		contactInfo = nil;
    }
}

void ContactListener::notifyObjects(b2Contact* contact, NSString* contactType)
{
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
	
    b2Body* bodyA = fixtureA->GetBody();
    b2Body* bodyB = fixtureB->GetBody();
	
    NSObject* objA = (__bridge NSObject*)bodyA->GetUserData();
    NSObject* objB = (__bridge NSObject*)bodyB->GetUserData();
	
    if ((objA != nil) && (objB != nil))
    {
        notifyAB(contact, contactType, fixtureA, objA, fixtureB, objB);
        notifyAB(contact, contactType, fixtureB, objB, fixtureA, objA);
    }
}

/// Called when two fixtures begin to touch.
void ContactListener::BeginContact(b2Contact* contact)
{
    notifyObjects(contact, @"begin");
}

/// Called when two fixtures cease to touch.
void ContactListener::EndContact(b2Contact* contact)
{
    notifyObjects(contact, @"end");
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	// do nothing (yet)
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	// do nothing (yet)
}
