//
//  GLESGameState.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface GLESGameState3D : GameState { //this should probably extend from glesGameState instead.
	int endgame_state;
	float endgame_complete_time;
}

- (void) startDraw;
- (void) swapBuffers;
- (BOOL) bindLayer;
+ (void) setup;

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;

//helper method used to convert a touch's screen coordinates to opengl coordinates.
- (CGPoint) touchPosition:(UITouch*)touch;

@end
