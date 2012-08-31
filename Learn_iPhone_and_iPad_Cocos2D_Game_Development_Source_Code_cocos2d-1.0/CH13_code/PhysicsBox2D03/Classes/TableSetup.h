//
//  StaticTable.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface TableSetup : CCNode
{
	b2World* world_;
}

+(id) setupTableWithWorld:(b2World*)world;

@end
