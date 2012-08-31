//
//  HelloWorldLayer.m
//  cocos2d-2.x-Chipmunk-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "PhysicsSprite.h"

static int contactBegin(cpArbiter* arbiter, struct cpSpace* space, void* data)
{
	BOOL processCollision = YES;
	
	cpBody* bodyA;
	cpBody* bodyB;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
	
    PhysicsSprite* spriteA = (__bridge PhysicsSprite*)bodyA->data;
    PhysicsSprite* spriteB = (__bridge PhysicsSprite*)bodyB->data;
    if (spriteA != nil && spriteB != nil)
    {
        spriteA.color = ccMAGENTA;
        spriteB.color = ccMAGENTA;
    }
	
    return processCollision;
}

static void contactEnd(cpArbiter* arbiter, cpSpace* space, void* data)
{
	cpBody* bodyA;
	cpBody* bodyB;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
	
    PhysicsSprite* spriteA = (__bridge PhysicsSprite*)bodyA->data;
    PhysicsSprite* spriteB = (__bridge PhysicsSprite*)bodyB->data;
    if (spriteA != nil && spriteB != nil)
    {
        spriteA.color = ccWHITE;
        spriteB.color = ccWHITE;
    }
}

@implementation HelloWorldLayer

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
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:36];
		label.position = ccp(screenSize.width / 2, screenSize.height - 30);
		[self addChild:label z:-1];
		
		CCSpriteBatchNode* batchNode = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png"];
		spriteTexture = batchNode.texture;
		[self addChild:batchNode z:0 tag:kTagBatchNode];
		
		[self initPhysics];
		[self addNewSpriteAtPosition:ccp(300, 200)];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	for (int i = 0; i < 4; i++)
	{
		cpShapeFree(walls[i]);
	}
	cpSpaceFree(space);
}

-(void) initPhysics
{
	cpInitChipmunk();
	space = cpSpaceNew();
	space->gravity = CGPointMake(0, -100);
	
	unsigned int defaultCollisionType = 0;
	cpSpaceAddCollisionHandler(space, defaultCollisionType, defaultCollisionType,
							   &contactBegin, NULL, NULL, &contactEnd, NULL);
	
	//
	// rogue shapes
	// We have to free them manually
	//
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float boxWidth = screenSize.width;
	float boxHeight = screenSize.height;
	// bottom
	walls[0] = cpSegmentShapeNew(space->staticBody, ccp(0, 0), ccp(boxWidth, 0), 0.0f);
	// top
	walls[1] = cpSegmentShapeNew(space->staticBody, ccp(0, boxHeight), ccp(boxWidth, boxHeight), 0.0f);
	// left
	walls[2] = cpSegmentShapeNew(space->staticBody, ccp(0, 0), ccp(0, boxHeight), 0.0f);
	// right
	walls[3] = cpSegmentShapeNew(space->staticBody, ccp(boxWidth, 0), ccp(boxWidth, boxHeight), 0.0f);
	
	for (int i = 0; i < 4; i++)
	{
		walls[i]->e = 1.0f;
		walls[i]->u = 1.0f;
		cpSpaceAddStaticShape(space, walls[i]);
	}
	
	[self addSomeJointedBodies:CGPointMake(120, 250)];
}

-(void) addSomeJointedBodies:(CGPoint)pos
{
    float mass = 1.0f;
    float moment = cpMomentForBox(mass, TILESIZE, TILESIZE);
	
    float halfTileSize = TILESIZE * 0.5f;
    int numVertices = 4;
    CGPoint vertices[] = 
    {
        ccp(-halfTileSize, -halfTileSize),
        ccp(-halfTileSize, halfTileSize),
        ccp(halfTileSize, halfTileSize),
        ccp(halfTileSize, -halfTileSize),
    };
	
    // Create a static body
    cpBody* staticBody = cpBodyNew(INFINITY, INFINITY);
    staticBody->p = pos;
	
    CGPoint offset = CGPointZero;
    cpShape* shape = cpPolyShapeNew(staticBody, numVertices, vertices, offset);
    cpSpaceAddStaticShape(space, shape);
	
    // Create three new dynamic bodies
    float posOffset = 1.4f;
    pos.x += TILESIZE * posOffset;
    cpBody* bodyA = cpBodyNew(mass, moment);
    bodyA->p = pos;
    cpSpaceAddBody(space, bodyA);
	
    shape = cpPolyShapeNew(bodyA, numVertices, vertices, offset);
    cpSpaceAddShape(space, shape);

	PhysicsSprite* spriteA = [self createPhysicsSpriteAt:pos];
	[spriteA setPhysicsBody:bodyA];
    bodyA->data = (__bridge void*)spriteA;

    pos.x += TILESIZE * posOffset;
    cpBody* bodyB = cpBodyNew(mass, moment);
    bodyB->p = pos;
    cpSpaceAddBody(space, bodyB);
	
    shape = cpPolyShapeNew(bodyB, numVertices, vertices, offset);
    cpSpaceAddShape(space, shape);

	PhysicsSprite* spriteB = [self createPhysicsSpriteAt:pos];
	[spriteB setPhysicsBody:bodyB];
    bodyB->data = (__bridge void*)spriteB;

    pos.x += TILESIZE * posOffset;
    cpBody* bodyC = cpBodyNew(mass, moment);
    bodyC->p = pos;
    cpSpaceAddBody(space, bodyC);
	
    shape = cpPolyShapeNew(bodyC, numVertices, vertices, offset);
	cpSpaceAddShape(space, shape);
	
	PhysicsSprite* spriteC = [self createPhysicsSpriteAt:pos];
	[spriteC setPhysicsBody:bodyC];
    bodyC->data = (__bridge void*)spriteC;

    // Create the joints and add the constraints to the space
    cpConstraint* constraint1 = cpPivotJointNew(staticBody, bodyA, staticBody->p);
    cpConstraint* constraint2 = cpPivotJointNew(bodyA, bodyB, bodyA->p);
    cpConstraint* constraint3 = cpPivotJointNew(bodyB, bodyC, bodyB->p);
	
    cpSpaceAddConstraint(space, constraint1);
    cpSpaceAddConstraint(space, constraint2);
    cpSpaceAddConstraint(space, constraint3);
}

-(void) update:(ccTime)delta
{
	const int iterations = 10;
	for (int i = 0; i < iterations; i++)
	{
		cpSpaceStep(space, 0.005f);
	}
}

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

-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	const int numVertices = 4;
	float halfTileSize = TILESIZE * 0.5f;
	CGPoint verts[] = 
	{
		ccp(-halfTileSize, -halfTileSize),
		ccp(-halfTileSize, halfTileSize),
		ccp(halfTileSize, halfTileSize),
		ccp(halfTileSize, -halfTileSize),
	};

	float mass = 1.0f;
	cpBody* body = cpBodyNew(mass, cpMomentForPoly(mass, numVertices, verts, CGPointZero));
	
	body->p = pos;
	cpSpaceAddBody(space, body);
	
	cpShape* shape = cpPolyShapeNew(body, numVertices, verts, CGPointZero);
	shape->e = 0.4f;
	shape->u = 0.4f;
	cpSpaceAddShape(space, shape);

	PhysicsSprite* sprite = [self createPhysicsSpriteAt:pos];
	[sprite setPhysicsBody:body];
	body->data = (__bridge void*)sprite;
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch* touch in touches)
	{
		CGPoint location = [touch locationInView:touch.view];
		location = [[CCDirector sharedDirector] convertToGL:location];
		[self addNewSpriteAtPosition:location];
	}
}

@end
