/*
 *  SpaceManagerCocos2d.m
 *  Example
 *
 *  Created by Robert Blackwood on 1/4/11.
 *  Copyright 2011 Mobile Bros. All rights reserved.
 *
 */

#import "SpaceManagerCocos2d.h"

//Debug Function!
static void createShapeNode(void *ptr, void *layer)
{
	cpShape *shape = (cpShape*)ptr;
	
	if (shape->data == NULL)
	{
		ccColor3B color = ccc3(rand()%256, rand()%256, rand()%256);
		
		cpShapeNode *node = [cpShapeNode nodeWithShape:shape];
		node.color = color;
		[(CCLayer*)layer addChild:node];
	}
}

//Debug Function!
static void createConstraintNode(void *ptr, void *layer)
{
	cpConstraint *constraint = (cpConstraint*)ptr;
	
	if (constraint->data == NULL)
	{
		ccColor3B color = ccc3(rand()%256, rand()%256, rand()%256);
		
		cpConstraintNode *node = [cpConstraintNode nodeWithConstraint:constraint];
		node.color = color;
		[(CCLayer*)layer addChild:node];
	}
}

/* Look into position_func off of cpBody for more efficient sync */
void smgrDefaultEachShape(void *ptr, void* data)
{
	cpShape *shape = (cpShape*)ptr;
	CCNode *node = (CCNode*)shape->data;
	
	if(node) 
	{
		cpBody *body = shape->body;
		[node setPosition:body->p];
		[node setRotation:CC_RADIANS_TO_DEGREES(-body->a)];
	}
}

void smgrEachShapeAsChildren(void *ptr, void* data)
{
	cpShape *shape = (cpShape*) ptr;
	
	CCNode *node = (CCNode*)shape->data;
	if(node) 
	{
		cpBody *body = shape->body;
		CCNode *parent = node.parent;
		if (parent)
		{
			[node setPosition:[node.parent convertToNodeSpace:body->p]];
			
			cpVect zPt = [node convertToWorldSpace:cpvzero];
			cpVect dPt = [node convertToWorldSpace:cpvforangle(body->a)];
			cpVect rPt = cpvsub(dPt,zPt);
			float angle = cpvtoangle(rPt);
			[node setRotation: CC_RADIANS_TO_DEGREES(-angle)];
		}
		else
		{
			[node setPosition:body->p];
			[node setRotation: CC_RADIANS_TO_DEGREES( -body->a )];
		}
	}
}

@implementation SpaceManagerCocos2d

-(id) initWithSpace:(cpSpace*)space
{
	[super initWithSpace:space];
	
	_iterateFunc = &smgrDefaultEachShape;
	
	return self;
}

-(void) dealloc
{
	[self stop];
	
	[super dealloc];
}

-(void) start:(ccTime)dt
{	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(step:) forTarget:self interval:dt paused:NO];
}

-(void) start
{
	[self start:0];
}

-(void) stop
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(step:) forTarget:self];
}

-(CCLayer*) createDebugLayer
{
	CCLayer *layer = [CCLayer node];
	
	cpSpaceHashEach(_space->activeShapes, createShapeNode, layer);
	cpSpaceHashEach(_space->staticShapes, createShapeNode, layer);
	
	cpArrayEach(_space->constraints, createConstraintNode, layer);
	
	return layer;
}

+(cpShapeNode*) createShapeNode:(cpShape*)shape
{
	cpShapeNode *node = nil;
	
	if (shape)
	{		
		node = [cpShapeNode nodeWithShape:shape];
		node.color = ccc3(rand()%256, rand()%256, rand()%256);
	}
	
	return node;
}

+(cpConstraintNode*) createConstraintNode:(cpConstraint*)constraint
{
	cpConstraintNode *node = nil;
	
	if (constraint)
	{
		node = [cpConstraintNode nodeWithConstraint:constraint];
		node.color = ccc3(rand()%256, rand()%256, rand()%256);
	}
	
	return node;
}

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset
{
	[self addWindowContainmentWithFriction:friction elasticity:elasticity inset:inset radius:1.0f];
}

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset radius:(cpFloat)radius
{
	CGSize wins = [[CCDirector sharedDirector] winSize];
	
	[self addWindowContainmentWithFriction:friction elasticity:elasticity size:wins inset:inset radius:radius];
}

@end

