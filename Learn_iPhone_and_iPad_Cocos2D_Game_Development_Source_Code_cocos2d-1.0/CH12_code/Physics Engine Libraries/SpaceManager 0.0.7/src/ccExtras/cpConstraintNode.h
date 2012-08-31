/*********************************************************************
 *	
 *	cpConstraintNode
 *
 *	cpConstraintNode.h
 *
 *	Provide Drawing for Constraints
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"
#import "chipmunk.h"
#import "SpaceManager.h"

@interface cpConstraintNode : CCNode <CCRGBAProtocol>
{
	cpConstraint *_constraint;
	
	BOOL			_autoFreeConstraint;
	SpaceManager	*_spaceManager;
	
	ccColor3B _color;
	GLubyte _opacity;
	
	cpFloat _pointSize;
	cpFloat _lineWidth;
	BOOL	_smoothDraw;
}
@property (readwrite, assign) cpConstraint* constraint;
@property (readwrite, assign) BOOL autoFreeConstraint;
@property (readwrite, assign) SpaceManager *spaceManager;

@property (readwrite, assign) ccColor3B color;
@property (readwrite, assign) GLubyte opacity;

@property (readwrite, assign) cpFloat pointSize;
@property (readwrite, assign) cpFloat lineWidth;
@property (readwrite, assign) BOOL smoothDraw;

+ (id) nodeWithConstraint:(cpConstraint*)c;
- (id) initWithConstraint:(cpConstraint*)c;


- (BOOL) containsPoint:(cpVect)pt padding:(cpFloat)padding;

@end
