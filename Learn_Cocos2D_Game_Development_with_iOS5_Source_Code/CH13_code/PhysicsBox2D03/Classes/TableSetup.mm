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

@interface TableSetup (PrivateMethods)
-(void) createStaticObject:(NSString*)name position:(CGPoint)position;
@end


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
    }
	
	return self;
}

+(id) setupTableWithWorld:(b2World*)world
{
	return [[[self alloc] initTableWithWorld:world] autorelease];
}

@end
