/*
 *  SpaceManagerCocos2d.h
 *  Example
 *
 *  Created by Robert Blackwood on 1/4/11.
 *  Copyright 2011 Mobile Bros. All rights reserved.
 *
 */

#import "cocos2d.h"
#import "SpaceManager.h"
#import "cpCCNode.h"
#import "cpCCSprite.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"

void smgrDefaultEachShape(void *ptr, void* data);
void smgrEachShapeAsChildren(void *ptr, void* data);

/*! A specialized sub-class of SpaceManager that adds specific Cocos2d functionality */
@interface SpaceManagerCocos2d : SpaceManager

/*! Schedule a timed loop (against step:) using Cocos2d's default dt */
-(void) start;

/*! Schedule a timed loop (against step:) using dt */
-(void) start:(float)dt;

/*! Stop the timed loop */
-(void) stop;

/*! Attach cpShapeNode's and cpConstraintNode's to shapes/constraints that have NULL data fields */
-(CCLayer*) createDebugLayer;

/*! Create [debug] node with random color */
+(cpShapeNode*) createShapeNode:(cpShape*)shape;

/*! Create [debug] node with random color */
+(cpConstraintNode*) createConstraintNode:(cpConstraint*)constraint;

/*! Convenience method for adding a containment rect around the view */
-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset;
-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset radius:(cpFloat)radius;

@end

