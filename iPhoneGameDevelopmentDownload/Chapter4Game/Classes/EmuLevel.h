//
//  TextureTest.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLESGameState.h"
@class TileWorld;
@class Emu;
@class Tom;
@class EmuMother;
//@class Entity;

@interface EmuLevel : GLESGameState {
	TileWorld* tileWorld;
	//NSMutableArray* world;
	Tom* m_tom;
	EmuMother* mama;
	Emu** flock;
	int flock_len;
}

@end
