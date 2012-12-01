//
//  TextureTest.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLESGameState.h"
#import "Rideable.h"
#import "Croc.h"
@class TileWorld;
@class Emu;
@class Tom;
@class Entity;

#define log_length 10
#define croc_length 5

@interface RiverLevel : GLESGameState {
	TileWorld* tileWorld;
	Tom* m_tom;
	Rideable* log[log_length];
	Croc *croc[croc_length];
	Entity* m_goal;
}

@end
