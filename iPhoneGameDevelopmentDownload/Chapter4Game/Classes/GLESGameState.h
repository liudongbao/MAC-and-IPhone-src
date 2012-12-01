//
//  GLESGameState.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface GLESGameState : GameState {
	int endgame_state;
@private
	float endgame_complete_time;
}

- (void) startDraw;
- (void) swapBuffers;
- (BOOL) bindLayer;
+ (void) setup2D;

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;

//helper method used to convert a touch's screen coordinates to opengl coordinates.
- (CGPoint) touchPosition:(UITouch*)touch;

#define WINNING 1
#define LOSING 2

- (void) onWin:(int)level;
- (void) onFail;
- (void) renderEndgame;
- (void) updateEndgame:(float)time;
- (void) touchEndgame;

@end
