/*********************************************************************
 *	
 *	cpCCNodeImpl.m
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCNode.h"


@implementation cpCCNodeImpl

@synthesize shape = _shape;
@synthesize ignoreRotation = _ignoreRotation;
@synthesize integrationDt = _integrationDt;
@synthesize spaceManager = _spaceManager;
@synthesize autoFreeShape = _autoFreeShape;

- (id) init
{
	return [self initWithShape:nil];
}

- (id) initWithShape:(cpShape*)s
{	
	_shape = s;
	_integrationDt = 0; //This should be off by default
	
	return self;
}

-(void) dealloc
{
	if (_shape)
	{
		_shape->data = NULL;
		if (_autoFreeShape)
		{
			assert(_spaceManager != nil);
			[_spaceManager removeAndFreeShape:_shape];
		}
	}
	_shape = nil;
		
	[super dealloc];
}

-(BOOL)setRotation:(float)rot
{	
	if (!_ignoreRotation)
	{	
		//Needs a calculation for angular velocity and such
		if (_shape != nil)
			cpBodySetAngle(_shape->body, -CC_DEGREES_TO_RADIANS(rot));
	}
	
	return !_ignoreRotation;
}

-(void)setPosition:(cpVect)pos
{	
	if (_shape != nil)
	{
		/* 
			A bit worried doing a != here but apparently copying around
			floats allows accurate comparisons.
		 */
		
		//If we're out of sync with chipmunk
		if (_shape->body->p.x != pos.x || _shape->body->p.y != pos.y)
		{
			//(Basic Euler integration)
			if (_integrationDt)
				cpBodySlew(_shape->body, pos, _integrationDt);
			
			//update position
			_shape->body->p = pos;
			
			//If we're static, we need to tell our space that we've changed
			if (_spaceManager && _shape->body->m == STATIC_MASS)
				[_spaceManager rehashShape:_shape];
			else //else activate!, could be sleeping
				cpBodyActivate(_shape->body);
		}
	}
}

-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset
{
	if (_shape != nil)
		cpBodyApplyImpulse(_shape->body, impulse, offset);
}

-(void) applyForce:(cpVect)force offset:(cpVect)offset
{
	if (_shape != nil)
		cpBodyApplyForce(_shape->body, force, offset);	
}

-(void) resetForces
{
	if (_shape != nil)
		cpBodyResetForces(_shape->body);
}

@end

