/*
 *  ContactListener.mm
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 *  Enhanced to use PhysicsEditor shapes and retina display
 *  by Andreas Loew / http://www.physicseditor.de
 *
 */

#import "ContactListener.h"
#import "BodyNode.h"

@implementation Contact

@synthesize otherObject, ownFixture, otherFixture, b2contact;

+(id) contactWithObject:(NSObject*)otherObject
		   otherFixture:(b2Fixture*)otherFixture
			 ownFixture:(b2Fixture*)ownFixture
			  b2Contact:(b2Contact*)b2contact
{
    Contact* contact = [[[Contact alloc] init] autorelease];

    if (contact)
    {
        contact.otherObject = otherObject;
        contact.otherFixture = otherFixture;
        contact.ownFixture = ownFixture;
        contact.b2contact = b2contact;
    }
    
    return contact;
}

-(id) retain
{
	[NSException raise:@"ContactRetainException"
				format:@"Do not retain a Contact - it is for temporary use only!"];
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
		
        Contact* contactInfo = [Contact contactWithObject:otherObj
                                             otherFixture:otherFixture
                                               ownFixture:fixture
                                                b2Contact:contact];
        [obj performSelector:contactSelector withObject:contactInfo];
    }
}

void ContactListener::notifyObjects(b2Contact* contact, NSString* contactType)
{
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();

    b2Body* bodyA = fixtureA->GetBody();
    b2Body* bodyB = fixtureB->GetBody();

    NSObject* objA = (NSObject*)bodyA->GetUserData();
    NSObject* objB = (NSObject*)bodyB->GetUserData();

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
