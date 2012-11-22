//
//  StaticTable.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "TableSetup.h"
#import "Constants.h"
#import "Helper.h"

@interface TableSetup (PrivateMethods)
-(void) addCircleBumperAt:(CGPoint)pos;
-(void) createTableTopBody;
-(void) createTableBottomLeftBody;
-(void) createTableBottomRightBody;
-(void) createLanes;
@end


@implementation TableSetup

-(id) initTableWithWorld:(b2World*)world
{
	if ((self = [super init]))
	{
		// weak reference to world for convenience
		world_ = world;
		
		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"table.png"];
		[self addChild:batch];

		CCSprite* tableTop = [CCSprite spriteWithSpriteFrameName:@"tabletop.png"];
		tableTop.position = [Helper screenCenter];
		[batch addChild:tableTop];

		CCSprite* tableBottom = [CCSprite spriteWithSpriteFrameName:@"tablebottom.png"];
		tableBottom.position = [Helper screenCenter];
		[batch addChild:tableBottom];

		[self createTableTopBody];
		//[self createTableBottomLeftBody];
		//[self createTableBottomRightBody];
		//[self createLanes];
		
		// world is no longer needed after init:
		world_ = NULL;
	}
	
	return self;
}

+(id) setupTableWithWorld:(b2World*)world
{
	return [[[self alloc] initTableWithWorld:world] autorelease];
}

-(void) createStaticBodyWithVertices:(b2Vec2[])vertices numVertices:(int)numVertices
{
	// Create a body definition
	b2BodyDef bodyDef;
	bodyDef.position = [Helper toMeters:[Helper screenCenter]];
	
	b2PolygonShape shape;
	shape.Set(vertices, numVertices);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
	fixtureDef.restitution = 0.1f;

	b2Body* body = world_->CreateBody(&bodyDef);
	body->CreateFixture(&fixtureDef);
}

-(void) createTableTopBody
{
	// table top
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(159.5f / PTM_RATIO, 125.5f / PTM_RATIO),
			b2Vec2(158.5f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(141.0f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(138.5f / PTM_RATIO, 167.5f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(138.0f / PTM_RATIO, 168.5f / PTM_RATIO),
			b2Vec2(138.0f / PTM_RATIO, 239.0f / PTM_RATIO),
			b2Vec2(87.5f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(86.0f / PTM_RATIO, 211.0f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(85.5f / PTM_RATIO, 211.5f / PTM_RATIO),
			b2Vec2(84.5f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(41.5f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(41.5f / PTM_RATIO, 224.5f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(41.0f / PTM_RATIO, 225.0f / PTM_RATIO),
			b2Vec2(40.0f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(-30.0f / PTM_RATIO, 240.0f / PTM_RATIO),
			b2Vec2(-30.5f / PTM_RATIO, 224.5f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-31.0f / PTM_RATIO, 224.5f / PTM_RATIO),
			b2Vec2(-31.5f / PTM_RATIO, 239.0f / PTM_RATIO),
			b2Vec2(-94.0f / PTM_RATIO, 240.0f / PTM_RATIO),
			b2Vec2(-93.5f / PTM_RATIO, 212.0f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-94.0f / PTM_RATIO, 211.5f / PTM_RATIO),
			b2Vec2(-96.5f / PTM_RATIO, 238.5f / PTM_RATIO),
			b2Vec2(-137.0f / PTM_RATIO, 239.0f / PTM_RATIO),
			b2Vec2(-134.5f / PTM_RATIO, 182.5f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-135.0f / PTM_RATIO, 182.0f / PTM_RATIO),
			b2Vec2(-139.0f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(-159.0f / PTM_RATIO, 239.5f / PTM_RATIO),
			b2Vec2(-159.0f / PTM_RATIO, 132.5f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
}
-(void) createTableBottomLeftBody
{
	// table bottom left
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-40.0f / PTM_RATIO, -240.0f / PTM_RATIO),
			b2Vec2(-47.0f / PTM_RATIO, -233.0f / PTM_RATIO),
			b2Vec2(-89.5f / PTM_RATIO, -224.5f / PTM_RATIO),
			b2Vec2(-88.5f / PTM_RATIO, -239.0f / PTM_RATIO),
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-90.5f / PTM_RATIO, -239.0f / PTM_RATIO),
			b2Vec2(-90.5f / PTM_RATIO, -223.0f / PTM_RATIO),
			b2Vec2(-150.0f / PTM_RATIO, -152.5f / PTM_RATIO),
			b2Vec2(-144.5f / PTM_RATIO, -239.0f / PTM_RATIO),
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(-146.5f / PTM_RATIO, -238.5f / PTM_RATIO),
			b2Vec2(-150.5f / PTM_RATIO, -152.5f / PTM_RATIO),
			b2Vec2(-159.0f / PTM_RATIO, -136.0f / PTM_RATIO),
			b2Vec2(-158.5f / PTM_RATIO, -238.0f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
}
-(void) createTableBottomRightBody
{
	// table bottom right
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(158.5f / PTM_RATIO, -239.0f / PTM_RATIO),
			b2Vec2(159.5f / PTM_RATIO, -201.0f / PTM_RATIO),
			b2Vec2(134.0f / PTM_RATIO, -201.0f / PTM_RATIO),
			b2Vec2(135.5f / PTM_RATIO, -237.0f / PTM_RATIO),
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 6;
		b2Vec2 vertices[] = {
			b2Vec2(133.0f / PTM_RATIO, -238.0f / PTM_RATIO),
			b2Vec2(133.0f / PTM_RATIO, -157.0f / PTM_RATIO),
			b2Vec2(128.0f / PTM_RATIO, -152.0f / PTM_RATIO),
			b2Vec2(120.5f / PTM_RATIO, -152.5f / PTM_RATIO),
			b2Vec2(115.0f / PTM_RATIO, -159.5f / PTM_RATIO),
			b2Vec2(113.0f / PTM_RATIO, -237.0f / PTM_RATIO),
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	{
		//row 1, col 1
		int num = 4;
		b2Vec2 vertices[] = {
			b2Vec2(111.0f / PTM_RATIO, -237.5f / PTM_RATIO),
			b2Vec2(112.5f / PTM_RATIO, -188.5f / PTM_RATIO),
			b2Vec2(34.0f / PTM_RATIO, -229.5f / PTM_RATIO),
			b2Vec2(26.0f / PTM_RATIO, -240.0f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
}
-(void) createLanes
{
	// right lane
	{
		//row 1, col 1
		int num = 5;
		b2Vec2 vertices[] = {
			b2Vec2(100.9f / PTM_RATIO, -143.9f / PTM_RATIO),
			b2Vec2(91.4f / PTM_RATIO, -145.0f / PTM_RATIO),
			b2Vec2(58.2f / PTM_RATIO, -164.4f / PTM_RATIO),
			b2Vec2(76.3f / PTM_RATIO, -185.5f / PTM_RATIO),
			b2Vec2(92.1f / PTM_RATIO, -176.1f / PTM_RATIO),
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
	// left lane
	{
		//row 1, col 1
		int num = 5;
		b2Vec2 vertices[] = {
			b2Vec2(-65.6f / PTM_RATIO, -165.1f / PTM_RATIO),
			b2Vec2(-119.3f / PTM_RATIO, -125.2f / PTM_RATIO),
			b2Vec2(-126.7f / PTM_RATIO, -128.3f / PTM_RATIO),
			b2Vec2(-126.7f / PTM_RATIO, -136.1f / PTM_RATIO),
			b2Vec2(-83.3f / PTM_RATIO, -175.6f / PTM_RATIO)
		};
		[self createStaticBodyWithVertices:vertices numVertices:num];
	}
}
@end
