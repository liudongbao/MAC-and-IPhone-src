//
//  Puyo.h
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "cocos2d.h"

@interface Puyo : Sprite {
	int boardX, boardY;
	int puyoType;
	BOOL stuck;
	BOOL disappearing;
}

@property int boardX;
@property int boardY;
@property int puyoType;
@property BOOL stuck;
@property BOOL disappearing;

+ (Puyo *) newPuyo;
- (void) moveUp;
- (void) moveDown;
- (void) moveLeft;
- (void) moveRight;

@end

// Macros to define puyo position on the screen based on board coordinates
#define COMPUTE_X(x) (abs(x) * 32)
#define COMPUTE_Y(y) abs(400 - (abs(y) * 32))
#define COMPUTE_X_Y(x,y) ccp( COMPUTE_X(x), COMPUTE_Y(y) )