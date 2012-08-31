//
//  HelloWorldLayer.mm
//  cocos2d-2.x-Box2D-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "PinballTableLayer.h"
#import "BodySprite.h"
#import "Constants.h"
#import "Helper.h"
#import "GB2ShapeCache.h"
#import "TableSetup.h"
#import "SimpleAudioEngine.h"

@implementation PinballTableLayer

+(CCScene*) scene
{
	CCScene* scene = [CCScene node];
	PinballTableLayer* layer = [PinballTableLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"bumper.wav"];

        // pre load the sprite frames from the texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pinball.plist"];
		
        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"pinball-shapes.plist"];
		
        // init the box2d world
        [self initPhysics];
		
        // load the background from the texture atlas
        CCSprite* background = [CCSprite spriteWithSpriteFrameName:@"background"];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        [self addChild:background z:-3];
		
        // Set up table elements
        TableSetup* tableSetup = [TableSetup setupTableWithWorld:world];
        [self addChild:tableSetup z:-1];
        
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
	world->SetContinuousPhysics(true);
	
	contactListener = new ContactListener();
	world->SetContactListener(contactListener);
	
	debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	flags += b2Draw::e_jointBit;
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

	// left
	groundBox.Set(b2Vec2(0, boxHeight), b2Vec2(0, 0));
	b2Fixture* left = groundBody->CreateFixture(&groundBox, density);
	// right
	groundBox.Set(b2Vec2(boxWidth, boxHeight), b2Vec2(boxWidth, 0));
	b2Fixture* right = groundBody->CreateFixture(&groundBox, density);
	
	// set the collision flags: category and mask
    b2Filter collisonFilter;
    collisonFilter.groupIndex = 0;
    collisonFilter.categoryBits = 0x0010; // category = Wall
    collisonFilter.maskBits = 0x0001;     // mask = Ball
	
    left->SetFilterData(collisonFilter);
    right->SetFilterData(collisonFilter);
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
	bodyDef.position = [Helper toMeters:pos];
	b2Body* body = world->CreateBody(&bodyDef);

	[self createBodyFixture:body];

	/*
	PhysicsSprite* sprite = [self createPhysicsSpriteAt:pos];
	[sprite setPhysicsBody:body];
	body->SetUserData((__bridge void*)sprite);
	 */
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
