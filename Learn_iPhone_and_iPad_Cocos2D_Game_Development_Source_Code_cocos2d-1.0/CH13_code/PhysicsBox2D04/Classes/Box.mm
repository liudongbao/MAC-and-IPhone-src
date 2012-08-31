//
//  Box.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 21.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Box.h"
#import "PinballTable.h"

@implementation Box

-(id) initWithWorld:(b2World*)world position:(CGPoint)pos
{
	if ((self = [super init]))
	{
		CCSpriteBatchNode* batch = [[PinballTable sharedTable] getSpriteBatch];
		
		float scaling = CCRANDOM_0_1() + 0.5f;
		int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
		int idy = CCRANDOM_0_1() * TILESET_ROWS;
		CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
		CCSprite* sprite = [CCSprite spriteWithBatchNode:batch rect:tileRect];
		sprite.position = pos;
		sprite.scale = scaling;
		[batch addChild:sprite];
		
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		// Create a body definition and set it to be a dynamic body
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position = [Helper toMeters:pos];
		bodyDef.userData = sprite;
		
		b2PolygonShape dynamicBox;
		float tileInMeters = (TILESIZE / PTM_RATIO) * scaling;
		dynamicBox.SetAsBox(tileInMeters * 0.5f, tileInMeters * 0.5f);
		
		// Define the dynamic body fixture.
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &dynamicBox;	
		fixtureDef.density = 0.1f / scaling;
		fixtureDef.friction = 0.2f / scaling;
		fixtureDef.restitution = 0.6f;
		
		[super createBodyInWorld:world bodyDef:&bodyDef fixtureDef:&fixtureDef];
	}
	return self;
}

+(id) boxWithWorld:(b2World*)world position:(CGPoint)pos
{
	return [[[self alloc] initWithWorld:world position:pos] autorelease];
}

@end
