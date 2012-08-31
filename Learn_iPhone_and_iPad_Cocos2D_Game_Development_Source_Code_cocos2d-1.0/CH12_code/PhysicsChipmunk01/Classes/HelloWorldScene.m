//
//  HelloWorldScene.m
//  PhysicsChipmunk
//
//  Created by Steffen Itterheim on 16.09.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"

#define TILESIZE 32
#define TILESET_COLUMNS 9
#define TILESET_ROWS 19


// C method that updates sprite position and rotation:
static void forEachShape(void* shapePointer, void* data)
{
	cpShape* shape = (cpShape*)shapePointer;
	CCSprite* sprite = (CCSprite*)shape->data;
	if (sprite != nil)
	{
		cpBody* body = shape->body;
		sprite.position = body->p;
		sprite.rotation = CC_RADIANS_TO_DEGREES(body->a) * -1;
	}
}


@interface HelloWorld (PrivateMethods)
-(void) addNewSpriteAt:(CGPoint)pos;
@end

@implementation HelloWorld

+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		cpInitChipmunk();
		
		space = cpSpaceNew();
		space->iterations = 8;
		space->gravity = CGPointMake(0, -100);
		
		// for the ground body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint lowerLeftCorner = CGPointMake(0, 0);
		CGPoint lowerRightCorner = CGPointMake(screenSize.width, 0);
		CGPoint upperLeftCorner = CGPointMake(0, screenSize.height);
		CGPoint upperRightCorner = CGPointMake(screenSize.width, screenSize.height);
		
		// Create the static body that keeps objects within the screen area
		float mass = INFINITY;
		float inertia = INFINITY;
		cpBody* staticBody = cpBodyNew(mass, inertia);
		
		cpShape* shape;
		float elasticity = 1.0f;
		float friction = 1.0f;
		float radius = 0.0f;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, lowerRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, upperLeftCorner, upperRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, upperLeftCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, lowerRightCorner, upperRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		[label setColor:ccc3(222, 222, 255)];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);
		
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png" capacity:150];
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		// Add a few objects initially
		for (int i = 0; i < 11; i++)
		{
			[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
		}
		
		[self scheduleUpdate];
		self.isTouchEnabled = YES;
	}
	
	return self;
}

-(void) dealloc
{
	cpSpaceFree(space);
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

-(void) addNewSpriteAt:(CGPoint)pos
{
	float mass = 0.5f;
	float moment = cpMomentForBox(mass, TILESIZE, TILESIZE);
	cpBody* body = cpBodyNew(mass, moment);
	
	body->p = pos;
	cpSpaceAddBody(space, body);
	
	float halfTileSize = TILESIZE * 0.5f;
	int numVertices = 4;
	CGPoint vertices[] = 
	{
		CGPointMake(-halfTileSize, -halfTileSize),
		CGPointMake(-halfTileSize, halfTileSize),
		CGPointMake(halfTileSize, halfTileSize),
		CGPointMake(halfTileSize, -halfTileSize),
	};

	CGPoint offset = CGPointZero;
	float elasticity = 0.3f;
	float friction = 0.7f;
	
	cpShape* shape = cpPolyShapeNew(body, numVertices, vertices, offset);
	shape->e = elasticity;
	shape->u = friction;
	shape->data = [self addRandomSpriteAt:pos];
	cpSpaceAddShape(space, shape);
}

-(void) update:(ccTime)delta
{
	float timeStep = 0.03f;
	cpSpaceStep(space, timeStep);
	
	// call forEachShape C method to update sprite positions
	cpSpaceHashEach(space->activeShapes, &forEachShape, nil);
	cpSpaceHashEach(space->staticShapes, &forEachShape, nil);
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
	for (UITouch* touch in touches) 
	{
		CGPoint location = [self locationFromTouches:touches];
		[self addNewSpriteAt:location];
	}
}

@end
