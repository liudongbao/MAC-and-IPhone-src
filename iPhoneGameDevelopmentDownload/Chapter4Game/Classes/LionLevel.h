//
//  LionLevel.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLESGameState.h"
@class TileWorld;
@class Emu;
@class Tom;
@class Lion;
@class Entity;

@interface LionLevel : GLESGameState {
	TileWorld* tileWorld;
	Tom* m_tom;
	Lion** m_lions;
	Entity* m_goal;
	int lions_length;
}	

@end
