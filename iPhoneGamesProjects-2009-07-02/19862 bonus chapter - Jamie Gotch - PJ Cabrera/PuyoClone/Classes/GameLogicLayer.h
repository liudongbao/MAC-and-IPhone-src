//
//  GameLogicLayer.h
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "Puyo.h"

@interface GameLogicLayer : Layer {
	enum touchTypes {
		kNone, 
		kDropPuyos, 
		kPuyoFlip, 
		kMoveLeft, 
		kMoveRight
	} touchType;
	
#define kLastColumn 9
#define kLastRow 12

	// The board is 10 puyos wide x 13 rows tall
	Puyo *board[kLastColumn + 1][kLastRow + 1];
	Puyo *puyo1, *puyo2;
	int frameCount;
	int moveCycleRatio;
	int difficulty;
	int score;
	Label *scoreLabel;
	Label *difficultyLabel;
	
	enum puyoOrientations {
		kPuyo2RightOfPuyo1,
		kPuyo2BelowPuyo1,
		kPuyo2LeftOfPuyo1,
		kPuyo2AbovePuyo1
	} puyoOrientation;
	
	NSMutableSet *currentGrouping;
	NSMutableSet *groupings;
}

- (void) updateBoard:(ccTime)dt;
@end
