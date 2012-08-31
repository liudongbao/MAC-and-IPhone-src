//
//  HelloWorldScene.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//


#import "HelloWorldScene.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define TILESIZE 32
#define TILESET_COLUMNS 9
#define TILESET_ROWS 19

@interface HelloWorld (PrivateMethods)
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
@end


@implementation HelloWorld

+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	return scene;
}

// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(id) init
{
	if ((self = [super init]))
	{
		// Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		bool allowBodiesToSleep = true;
		world = new b2World(gravity, allowBodiesToSleep);
		
		contactListener = new ContactListener();
		world->SetContactListener(contactListener);

		// Define the static container body, which will provide the collisions at screen borders.
		b2BodyDef containerBodyDef;
		b2Body* containerBody = world->CreateBody(&containerBodyDef);

		// for the ground body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		float widthInMeters = screenSize.width / PTM_RATIO;
		float heightInMeters = screenSize.height / PTM_RATIO;
		b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
		b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
		b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
		b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);

		// Create the screen box' sides by using a polygon assigning each side individually.
		b2PolygonShape screenBoxShape;
		int density = 0;

		// bottom
		screenBoxShape.SetAsEdge(lowerLeftCorner, lowerRightCorner);
		containerBody->CreateFixture(&screenBoxShape, density);
		
		// top
		screenBoxShape.SetAsEdge(upperLeftCorner, upperRightCorner);
		containerBody->CreateFixture(&screenBoxShape, density);
		
		// left side
		screenBoxShape.SetAsEdge(upperLeftCorner, lowerLeftCorner);
		containerBody->CreateFixture(&screenBoxShape, density);
		
		// right side
		screenBoxShape.SetAsEdge(upperRightCorner, lowerRightCorner);
		containerBody->CreateFixture(&screenBoxShape, density);
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		[label setColor:ccc3(222, 222, 255)];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);

		// Use the orthogonal tileset for the little boxes
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png" capacity:TILESET_ROWS * TILESET_COLUMNS];
		[self addChild:batch z:0 tag:kTagBatchNode];

		// Add a few objects initially
		for (int i = 0; i < 9; i++)
		{
			[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
		}

		[self addSomeJoinedBodies:CGPointMake(screenSize.width / 4, screenSize.height - 50)];
		
		[self scheduleUpdate];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) dealloc
{
	delete contactListener;
	delete world;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(CCSprite*) addRandomSpriteAt:(CGPoint)pos
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
	
	int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
	int idy = CCRANDOM_0_1() * TILESET_ROWS;
	CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
	CCSprite* sprite = [CCSprite spriteWithBatchNode:batch rect:tileRect];
	sprite.position = pos;
	[batch addChild:sprite];
	
	return sprite;
}

-(void) bodyCreateFixture:(b2Body*)body
{
	// Define another box shape for our dynamic bodies.
	b2PolygonShape dynamicBox;
	float tileInMeters = TILESIZE / PTM_RATIO;
	dynamicBox.SetAsBox(tileInMeters * 0.5f, tileInMeters * 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 0.3f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	
}

-(void) addSomeJoinedBodies:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(-1, -1);
	bodyDef.userData = [self addRandomSpriteAt:pos];
	b2Body* bodyA = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyA];

	bodyDef.position = [self toMeters:pos];
	bodyDef.userData = [self addRandomSpriteAt:pos];
	b2Body* bodyB = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyB];

	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(1, 1);
	bodyDef.userData = [self addRandomSpriteAt:pos];
	b2Body* bodyC = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyC];

	b2RevoluteJointDef jointDef;
	jointDef.Initialize(bodyA, bodyB, bodyB->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);

	jointDef.Initialize(bodyB, bodyC, bodyC->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);

	// create an invisible static body to attach to
	bodyDef.type = b2_staticBody;
	bodyDef.position = [self toMeters:pos];
	b2Body* staticBody = world->CreateBody(&bodyDef);
	jointDef.Initialize(staticBody, bodyA, bodyA->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
}

-(void) addNewSpriteAt:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
	bodyDef.userData = [self addRandomSpriteAt:pos];
	b2Body* body = world->CreateBody(&bodyDef);

	[self bodyCreateFixture:body];
}

-(void) update:(ccTime)delta
{
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	// for each body, get its assigned sprite and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		CCSprite* sprite = (CCSprite*)body->GetUserData();
		if (sprite != NULL)
		{
			// update the sprite's position to where their physics bodies are
			sprite.position = [self toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
		}
	}
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for (UITouch* touch in touches) 
	{
		CGPoint location = [self locationFromTouches:touches];
		[self addNewSpriteAt:location];
	}
}

@end
