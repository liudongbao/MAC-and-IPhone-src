//
//  TableSetup.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "TableSetup.h"
#import "Constants.h"
#import "TablePart.h"
#import "Ball.h"
#import "Bumper.h"
#import "Plunger.h"
#import "Flipper.h"

@implementation TableSetup
-(id) initTableWithWorld:(b2World*)world
{
	if ((self = [super initWithFile:@"pinball.pvr.ccz" capacity:5]))
	{		
        // add the table blocks
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 480)
											  name:@"table-top"]];
		
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 0)
											  name:@"table-bottom"]];
		
        [self addChild:[TablePart tablePartInWorld:world
										  position:ccp(0, 263)
											  name:@"table-left"]];
		
		// Add some bumpers
		[self addBumperAt:ccp( 76, 405) inWorld:world];
		[self addBumperAt:ccp(158, 415) inWorld:world];
		[self addBumperAt:ccp(239, 375) inWorld:world];
		[self addBumperAt:ccp( 83, 341) inWorld:world];
		[self addBumperAt:ccp(157, 294) inWorld:world];
		[self addBumperAt:ccp(260, 286) inWorld:world];
		[self addBumperAt:ccp( 67, 228) inWorld:world];
		[self addBumperAt:ccp(183, 189) inWorld:world];

		Ball* ball = [Ball ballWithWorld:world];
		[self addChild:ball z:-1];
		
		// Add flippers
        Flipper *left = [Flipper flipperWithWorld:world flipperType:kFlipperLeft];
        [self addChild:left];
        
        Flipper *right = [Flipper flipperWithWorld:world flipperType:kFlipperRight];
        [self addChild:right];

		// Add plunger
		Plunger *plunger = [Plunger plungerWithWorld:world];
		[self addChild:plunger z:-1];
    }
	
	return self;
}

+(id) setupTableWithWorld:(b2World*)world
{
	return [[self alloc] initTableWithWorld:world];
}

-(void) addBumperAt:(CGPoint)pos inWorld:(b2World*)world
{
	Bumper* bumper = [Bumper bumperWithWorld:world position:pos];
	[self addChild:bumper];
}

@end
