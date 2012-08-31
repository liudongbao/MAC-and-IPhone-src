//
//  HelloWorldScene.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//


#import "PinballTable.h"
#import "Constants.h"
#import "Helper.h"
#import "TableSetup.h"
#import "BodyNode.h"

@interface PinballTable (PrivateMethods)
-(void) initBox2dWorld;
-(void) enableBox2dDebugDrawing;
@end


@implementation PinballTable

static PinballTable* pinballTableInstance;

+(PinballTable*) sharedTable
{
	NSAssert(pinballTableInstance != nil, @"table not yet initialized!");
	return pinballTableInstance;
}

+(id) scene
{
	CCScene* scene = [CCScene node];
	PinballTable* layer = [PinballTable node];
	[scene addChild:layer];
	return scene;
}


-(id) init
{
	if ((self = [super init]))
	{
		pinballTableInstance = self;

		[self initBox2dWorld];
		[self enableBox2dDebugDrawing];
		
		// preload the sprite frames from the texture atlas
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"table.plist"];

		// a bright background is desireable for this pinball table
		CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(222, 222, 222, 255)];
		[self addChild:colorLayer z:-3];

		// batch node for all dynamic elements
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"table.png" capacity:100];
		[self addChild:batch z:-2 tag:kTagBatchNode];
		
		// Setup static elements
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
	
	delete contactListener;
	contactListener = NULL;
	
	delete debugDraw;
	debugDraw = NULL;

	pinballTableInstance = nil;

	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) initBox2dWorld
{
	// Construct a world object, which will hold and simulate the rigid bodies.
	b2Vec2 gravity = b2Vec2(0.0f, -5.0f);
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
	
	// We only need the sides for the table:
	// left side
	screenBoxShape.SetAsEdge(upperLeftCorner, lowerLeftCorner);
	containerBody->CreateFixture(&screenBoxShape, density);
	
	// right side
	screenBoxShape.SetAsEdge(upperRightCorner, lowerRightCorner);
	containerBody->CreateFixture(&screenBoxShape, density);
}

-(void) enableBox2dDebugDrawing
{
	// Debug Draw functions
	debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(debugDraw);
	
	uint32 flags = 0;
	flags |= b2DebugDraw::e_shapeBit;
	flags |= b2DebugDraw::e_jointBit;
	//flags |= b2DebugDraw::e_aabbBit;
	//flags |= b2DebugDraw::e_pairBit;
	//flags |= b2DebugDraw::e_centerOfMassBit;
	debugDraw->SetFlags(flags);		
}

-(CCSpriteBatchNode*) getSpriteBatch
{
	return (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
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
	
	// for each body, get its assigned BodyNode and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		BodyNode* bodyNode = (BodyNode*)body->GetUserData();
		if (bodyNode != NULL && bodyNode.sprite != nil)
		{
			// update the sprite's position to where their physics bodies are
			bodyNode.sprite.position = [Helper toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			bodyNode.sprite.rotation = -(CC_RADIANS_TO_DEGREES(angle));
		}
	}
}

#ifdef DEBUG
-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}
#endif

@end
