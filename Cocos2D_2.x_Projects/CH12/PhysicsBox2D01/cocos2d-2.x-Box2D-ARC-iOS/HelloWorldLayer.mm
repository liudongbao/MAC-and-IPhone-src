//
//  HelloWorldLayer.mm
//  cocos2d-2.x-Box2D-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "PhysicsSprite.h"

@implementation HelloWorldLayer

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

+(CCScene*) scene
{
	CCScene* scene = [CCScene node];
	HelloWorldLayer* layer = [HelloWorldLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		self.isTouchEnabled = YES;
		
		CCSpriteBatchNode* batchNode = [CCSpriteBatchNode 
										batchNodeWithFile:@"dg_grounds32.png"];
		spriteTexture = batchNode.texture;
		[self addChild:batchNode z:0 tag:kTagBatchNode];

		[self initPhysics];

		CGSize screenSize = [CCDirector sharedDirector].winSize;
		[self addNewSpriteAtPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Tap screen" 
											   fontName:@"Marker Felt" 
											   fontSize:32];
		[self addChild:label z:0];
		label.color = ccc3(0, 0, 255);
		label.position = ccp(screenSize.width / 2, screenSize.height - 50);
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	delete debugDraw;
	debugDraw = NULL;
	delete contactListener;
	contactListener = NULL;
}

-(void) initPhysics
{
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	world->SetAllowSleeping(true);
	world->SetContinuousPhysics(false);
	
	contactListener = new ContactListener();
	world->SetContactListener(contactListener);
	
	debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	debugDraw->SetFlags(flags);		
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float boxWidth = screenSize.width / PTM_RATIO;
	float boxHeight = screenSize.height / PTM_RATIO;
	b2EdgeShape groundBox;
	int density = 0;
	// bottom
	groundBox.Set(b2Vec2(0, 0), b2Vec2(boxWidth, 0));
	groundBody->CreateFixture(&groundBox, density);
	// top
	groundBox.Set(b2Vec2(0, boxHeight), b2Vec2(boxWidth, boxHeight));
	groundBody->CreateFixture(&groundBox, density);
	// left
	groundBox.Set(b2Vec2(0, boxHeight), b2Vec2(0, 0));
	groundBody->CreateFixture(&groundBox, density);
	// right
	groundBox.Set(b2Vec2(boxWidth, boxHeight), b2Vec2(boxWidth, 0));
	groundBody->CreateFixture(&groundBox, density);

	[self addSomeJointedBodies:CGPointMake(screenSize.width / 4, screenSize.height - 50)];
}

-(void) addSomeJointedBodies:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(-1, -1);
	b2Body* bodyA = world->CreateBody(&bodyDef);
	[self createBodyFixture:bodyA];

	PhysicsSprite* spriteA = [self createPhysicsSpriteAt:pos];
	[spriteA setPhysicsBody:bodyA];
	bodyA->SetUserData((__bridge void*)spriteA);
	
	bodyDef.position = [self toMeters:pos];
	b2Body* bodyB = world->CreateBody(&bodyDef);
	[self createBodyFixture:bodyB];
	
	PhysicsSprite* spriteB = [self createPhysicsSpriteAt:pos];
	[spriteB setPhysicsBody:bodyB];
	bodyB->SetUserData((__bridge void*)spriteB);
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(1, 1);
	b2Body* bodyC = world->CreateBody(&bodyDef);
	[self createBodyFixture:bodyC];
	
	PhysicsSprite* spriteC = [self createPhysicsSpriteAt:pos];
	[spriteC setPhysicsBody:bodyC];
	bodyC->SetUserData((__bridge void*)spriteC);
	
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

#if DEBUG
-(void) draw
{
	[super draw];
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	world->DrawDebugData();	
	kmGLPopMatrix();
}
#endif

-(PhysicsSprite*) createPhysicsSpriteAt:(CGPoint)pos
{
	CCLOG(@"Add sprite %0.2f, %02.f", pos.x, pos.y);
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
	int idy = CCRANDOM_0_1() * TILESET_ROWS;
	CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
	PhysicsSprite* sprite = [PhysicsSprite spriteWithTexture:spriteTexture rect:tileRect];
	sprite.position = pos;
	
	CCNode* batchNode = [self getChildByTag:kTagBatchNode];
	[batchNode addChild:sprite];
	
	return sprite;
}

-(void) createBodyFixture:(b2Body*)body
{
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(0.5f, 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}

-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = [self toMeters:pos];
	b2Body* body = world->CreateBody(&bodyDef);

	[self createBodyFixture:body];
	
	PhysicsSprite* sprite = [self createPhysicsSpriteAt:pos];
	[sprite setPhysicsBody:body];
	body->SetUserData((__bridge void*)sprite);
}

-(void) update:(ccTime)delta
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(delta, velocityIterations, positionIterations);	
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for (UITouch* touch in touches)
	{
		CGPoint location = [touch locationInView:touch.view];
		location = [[CCDirector sharedDirector] convertToGL:location];
		[self addNewSpriteAtPosition:location];
	}
}

@end
