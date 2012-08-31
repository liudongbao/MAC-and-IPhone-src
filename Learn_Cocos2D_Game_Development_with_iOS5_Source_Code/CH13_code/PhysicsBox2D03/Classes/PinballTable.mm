//
//  PinballTable.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "PinballTable.h"
#import "Constants.h"
#import "Helper.h"
#import "TableSetup.h"
#import "GB2ShapeCache.h"
#import "b2PolygonShape.h"
#import "b2Math.h"
#import "b2Body.h"
#import "b2Fixture.h"
#import "BodyNode.h"
#import "b2Settings.h"

@interface PinballTable (PrivateMethods)
-(void) initBox2dWorld;
-(void) enableBox2dDebugDrawing;
@end

@implementation PinballTable

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
		// pre load the sprite frames from the texture atlas
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pinball.plist"];

        // load physics definitions
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"pinball-shapes.plist"];

        // init the box2d world
		[self initBox2dWorld];

        // debug drawing
		[self enableBox2dDebugDrawing];

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
	
	delete contactListener;
	contactListener = NULL;
	
	delete debugDraw;
	debugDraw = NULL;

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
	float density = 0.0;

	// We only need the sides for the table:
	// left side
	screenBoxShape.SetAsEdge(upperLeftCorner, lowerLeftCorner);
	b2Fixture *left = containerBody->CreateFixture(&screenBoxShape, density);
	
	// right side
	screenBoxShape.SetAsEdge(upperRightCorner, lowerRightCorner);
	b2Fixture *right = containerBody->CreateFixture(&screenBoxShape, density);

    // set the collision flags: category and mask
    b2Filter collisonFilter;
    collisonFilter.groupIndex = 0;
    collisonFilter.categoryBits = 0x0010; // category = Wall
    collisonFilter.maskBits = 0x0001;     // mask = Ball

    left->SetFilterData(collisonFilter);
    right->SetFilterData(collisonFilter);
}

-(void) enableBox2dDebugDrawing
{
	// Debug Draw functions
	debugDraw = new GLESDebugDraw([[CCDirector sharedDirector] contentScaleFactor] * PTM_RATIO);
	world->SetDebugDraw(debugDraw);
	
	uint32 flags = 0;
	flags |= b2DebugDraw::e_shapeBit;
	flags |= b2DebugDraw::e_jointBit;
	//flags |= b2DebugDraw::e_aabbBit;
	//flags |= b2DebugDraw::e_pairBit;
	//flags |= b2DebugDraw::e_centerOfMassBit;
	debugDraw->SetFlags(flags);
}

-(void) update:(ccTime)delta
{
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(delta, velocityIterations, positionIterations);

	// for each body, get its assigned BodyNode and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		BodyNode* bodyNode = (BodyNode*)body->GetUserData();
		if (bodyNode != nil)
		{
			// update the sprite's position to where their physics bodies are
			bodyNode.position = [Helper toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			bodyNode.rotation = -(CC_RADIANS_TO_DEGREES(angle));
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
