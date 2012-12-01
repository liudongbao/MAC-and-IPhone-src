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
@class MazeDoor;
@class MazeButton;
@class Entity;

#define buttons_length 3

typedef enum MazeState {
	MOVING_MOUSE=0,
	MOVING_CAT,
	WAITING_FOR_PLAYER,
	GOT_CHEESE, //winning state
	MOUSE_KILLED, //losing state
} MazeState;

@interface MazeLevel : GLESGameState {
	TileWorld* tileWorld;
	Tom* m_tom;
	Tom *cat, *mouse;
	Entity* cheese;
	MazeDoor* door[2][2][3];
	MazeButton* buttons[buttons_length];
	MazeState state;
}

- (void) decorateDoors;
- (NSArray*) possibleMoves:(Entity*) guy;
- (MazeDoor*) doorFrom:(CGPoint) pos inDirection:(int) angle;

@end
