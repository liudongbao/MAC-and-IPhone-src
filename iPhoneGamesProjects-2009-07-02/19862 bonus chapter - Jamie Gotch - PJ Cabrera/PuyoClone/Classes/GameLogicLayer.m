//
//  GameLogicLayer.m
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "GameLogicLayer.h"

// list private methods here
@interface GameLogicLayer (private)

- (void) startGame;
- (void) clearBoard;
- (void) tryToCreateNewPuyos;
- (void) createNewPuyos;
- (void) gameOver;

- (void) processTaps;
- (void) disappearPuyos;
- (void) movePuyosDown;
- (void) findPuyoGroupings;
- (void) computeScore;
- (void) determineDifficultyIncrease;
- (void) updateInfoDisplays;

- (void) detectStrayGrouping;
- (void) checkForPuyoGroupings:(Puyo *)p1;

- (void) movePuyoLeft:(Puyo *)puyo;
- (void) movePuyoRight:(Puyo *)puyo;
- (void) movePuyoDown:(Puyo *)puyo;
- (void) movePuyoUp:(Puyo *)puyo;

@end

@implementation GameLogicLayer

- (id) init {
    self = [super init];
    if (self != nil) {
		// this tells Cocos2d to call our touch event handlers
		isTouchEnabled = YES;
		
		[self startGame];		
    }
    return self;
}

- (void) dealloc {
	[self clearBoard];
	[self removeAllChildrenWithCleanup:YES];
	[difficultyLabel release];
	[scoreLabel release];
	[super dealloc];
}

- (void) startGame {
	difficultyLabel = [[LabelAtlas labelAtlasWithString:@"1" 
		charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 
		startCharMap:'.'] retain];
	difficultyLabel.position = ccp(110, 452);
	[self addChild:difficultyLabel z:0];
	
	scoreLabel = [[LabelAtlas labelAtlasWithString:@"00000" 
		charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 
		startCharMap:'.'] retain];
	scoreLabel.position = ccp(230, 452);
	[self addChild:scoreLabel z:0];
	
	// clear the board
	memset(board, 0, sizeof(board));
	
	[self createNewPuyos];
	difficulty = 1;
	score = 0;
	frameCount = 0;
	moveCycleRatio = 45; // Drop puyos every 3/4 second 

	// Execute updateBoard 60 times per second.
	[self schedule:@selector(updateBoard:) interval: 1.0 / 60.0];
}

- (void) tryToCreateNewPuyos {
	
	// Are the spots for new puyos empty?
	if (nil != board[4][0] || nil != board[5][0]) {
		// No, they're not empty.
		
		[self gameOver];
		
	} else {
		// Yes, the spots are empty.
		
		[self createNewPuyos];
		
	}
}

/* This method creates puyo1 and puyo2 next to each other,
 and sets the default orientation. */
- (void) createNewPuyos {
	// Class Puyo is derived from Cocos2D class Sprite, which is 
	// autoreleased. We need to retain the puyos or Cocos2D will 
	// autorelease them right from under our noses and crash the game!
	puyo1 = [[Puyo newPuyo] retain];
	board[4][0] = puyo1;
	puyo1.boardX = 4; puyo1.boardY = 0;
	puyo1.position = COMPUTE_X_Y(4,0);
	[self addChild:puyo1 z:2];
	
	puyo2 = [[Puyo newPuyo] retain];
	board[5][0] = puyo2;
	puyo2.boardX = 5; puyo2.boardY = 0;
	puyo2.position = COMPUTE_X_Y(5,0);
	[self addChild:puyo2 z:2];
	
	puyoOrientation = kPuyo2RightOfPuyo1;
}

- (void) gameOver {
	// Stop the game loop ...
	[self unschedule:@selector(updateFrame:)];
	
	// ... and display the game over graphic.
	Sprite *gameover = [Sprite spriteWithFile:@"gameover.png"];
	gameover.position = ccp(160, 240);
	gameover.opacity = 255;
	[self addChild:gameover z:3];
}

// This method is the game logic loop. It gets called 60 times per second
- (void) updateBoard:(ccTime)dt {
	frameCount++;
	[self processTaps];
	[self disappearPuyos];

	// It really doesn't make sense to run these 60 times per second
	if (frameCount % moveCycleRatio == 0) {
		[self movePuyosDown];
		[self findPuyoGroupings];
		[self computeScore];
		[self determineDifficultyIncrease];
		[self updateInfoDisplays];
	}
}

// We only care about single taps, so we listen to the events generated
//    when the user lifts their finger off the screen
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView: [touch view]];
	
	// To compare Cocos2D Sprite positions to UITouch coordinates,
	// we need to flip UITouch y coordinate upside down for portrait mode.
	point.y = 480 - point.y;
	
	// If the touch was within 32 pixels of the pair of puyos, 
	// the touch was a request to flip the puyos.
	if ( !puyo1.stuck && !puyo2.stuck && 
		( abs((int)puyo1.position.x - (int)point.x) < 32 && 
		 abs((int)puyo1.position.y - (int)point.y) < 32 ) ||
		( abs((int)puyo2.position.x - (int)point.x) < 32 && 
		 abs((int)puyo2.position.y - (int)point.y) < 32 ) ) 
	{
		
		touchType = kPuyoFlip;
		
	}
	
	else if ((int)point.y < 68) touchType = kDropPuyos;
	
	else if ((int)point.x < 116) touchType = kMoveLeft;
	
	else if ((int)point.x > 204) touchType = kMoveRight;
	
	return kEventHandled;
}

- (void) processTaps {	
	if (touchType == kPuyoFlip) {
		// Reset touch type
		touchType = kNone;
		
		// Are puyo1 & puyo2 stuck? Are they next to each other?
		if (!puyo1.stuck && !puyo2.stuck &&
			abs(puyo1.boardX - puyo2.boardX) <= 1 &&
			abs(puyo1.boardY - puyo2.boardY) <= 1) 
		{
			// They're not stuck and they're next to each other.
			
			// Move puyo2 into position depending on current orientation.
			switch (puyoOrientation) {
				case kPuyo2RightOfPuyo1:
					if ( (puyo1.boardY + 1) <= kLastRow && 
						nil == board[puyo1.boardX][puyo1.boardY + 1]) 
					{
						[self movePuyoDown:puyo2];
						[self movePuyoLeft:puyo2];
						puyoOrientation = kPuyo2BelowPuyo1;
					}
					break;
				case kPuyo2BelowPuyo1:
					if ( (puyo1.boardX - 1) >= 0 && 
						nil == board[puyo1.boardX - 1][puyo1.boardY]) 
					{
						[self movePuyoLeft:puyo2];
						[self movePuyoUp:puyo2];
						puyoOrientation = kPuyo2LeftOfPuyo1;
					}
					break;
				case kPuyo2LeftOfPuyo1:
					if ( (puyo1.boardY - 1) >= 0 && 
						nil == board[puyo1.boardX][puyo1.boardY - 1]) 
					{
						[self movePuyoUp:puyo2];
						[self movePuyoRight:puyo2];
						puyoOrientation = kPuyo2AbovePuyo1;
					}
					break;
				case kPuyo2AbovePuyo1:
					if ( (puyo1.boardX + 1) <= kLastColumn && 
						nil == board[puyo1.boardX + 1][puyo1.boardY]) 
					{
						[self movePuyoRight:puyo2];
						[self movePuyoDown:puyo2];
						puyoOrientation = kPuyo2RightOfPuyo1;
					}
					break;
			}
			
		}
	} else if (touchType == kMoveLeft) {
		// Reset touch type
		touchType = kNone;
		
		// Determine the leftmost puyo so that it will be moved first.
		Puyo *p1, *p2;
		if (puyo1.boardX < puyo2.boardX) {
			p1 = puyo1; p2 = puyo2;
		} else {
			p1 = puyo2; p2 = puyo1;
		}
		
		// Move puyo left if not stuck and if nothing to its left.
		if (p1.boardX > 0 && !p1.stuck) {
			if (nil == board[p1.boardX - 1][p1.boardY]) {
				[self movePuyoLeft: p1];
			}
		}
		
		// Move puyo left if not stuck and if nothing to its left.
		if (p2.boardX > 0 && !p2.stuck) {
			if (nil == board[p2.boardX - 1][p2.boardY]) {
				[self movePuyoLeft: p2];
			}
		}
		
	} else if (touchType == kMoveRight) {
		// Reset touch type
		touchType = kNone;
		
		// Determine the rightmost puyo so that it will be moved first.
		Puyo *p1, *p2;
		if (puyo1.boardX > puyo2.boardX) {
			p1 = puyo1; p2 = puyo2;
		} else {
			p1 = puyo2; p2 = puyo1;
		}
		
		// Move puyo right if not stuck and if nothing to its right.
		if (p1.boardX < kLastColumn && !p1.stuck) {
			if (nil == board[p1.boardX + 1][p1.boardY]) {
				[self movePuyoRight: p1];
			}
		}
		// Move puyo right if not stuck and if nothing to its right.
		if (p2.boardX < kLastColumn && !p2.stuck) {
			if (nil == board[p2.boardX + 1][p2.boardY]) {
				[self movePuyoRight: p2];
			}
		}
		
	} else if (touchType == kDropPuyos) {
		// Reset touch type
		touchType = kNone;
		
		// Determine the bottommost puyo so that it will be moved first.
		Puyo *p1, *p2;
		if (puyo1.boardY > puyo2.boardY) {
			p1 = puyo1; p2 = puyo2;
		} else {
			p1 = puyo2; p2 = puyo1;
		}
		// If not stuck, move puyo down until stuck by a block or 
		//    until reaching the last row.
		if (!p1.stuck) {
			while (p1.boardY != kLastRow && 
				   nil == board[p1.boardX][p1.boardY + 1]) 
			{
				[self movePuyoDown: p1];
			}
		}
		// If not stuck, move puyo down until stuck by a block or 
		//    until reaching the last row.
		if (!p2.stuck) {
			while (p2.boardY != kLastRow && 
				   nil == board[p2.boardX][p2.boardY + 1]) 
			{
				[self movePuyoDown: p2];
			}
		}		
	} // End of if (touchType ...
}

- (void) movePuyoLeft:(Puyo *)puyo {
	board[puyo.boardX][puyo.boardY] = nil;
	board[puyo.boardX - 1][puyo.boardY] = puyo;
	puyo.moveLeft;
}

- (void) movePuyoRight:(Puyo *)puyo {
	board[puyo.boardX][puyo.boardY] = nil;
	board[puyo.boardX + 1][puyo.boardY] = puyo;
	puyo.moveRight;
}

- (void) movePuyoDown:(Puyo *)puyo {
	board[puyo.boardX][puyo.boardY] = nil;
	board[puyo.boardX][puyo.boardY + 1] = puyo;
	puyo.moveDown;
}

- (void) movePuyoUp:(Puyo *)puyo {
	board[puyo.boardX][puyo.boardY] = nil;
	board[puyo.boardX][puyo.boardY - 1] = puyo;
	puyo.moveUp;
}

- (void) findPuyoGroupings {
	groupings = [[NSMutableSet alloc] init];
	
	// This whole block looks for matching puyos horizontally
	for (int y = 0; y <= kLastRow; y++) {
		
		// Create a new current grouping set for each row.
		currentGrouping = [[NSMutableSet alloc] init];
		
		for (int x = 0; x <= kLastColumn; x++) {
			
			[self checkForPuyoGroupings: board[x][y]];
			
		} // End of for x loop				
		
		[self detectStrayGrouping];
		
	} // End of for y loop
	
	// This whole block looks for matching puyos vertically
	for (int x = 0; x <= kLastColumn; x++) {
		
		// Create a new current grouping set for each column.
		currentGrouping = [[NSMutableSet alloc] init];
		
		for (int y = 0; y <= kLastRow; y++) {
			
			[self checkForPuyoGroupings: board[x][y]];
			
		} // End of for y loop
		
		[self detectStrayGrouping];
		
	} // End of for x loop
}

// Sometimes we get to the end of a column and there's a grouping.
// The code below makes sure we add it to set of all groupings.
- (void) detectStrayGrouping {
	// Current grouping set contains more than 3 puyos?
	if ([currentGrouping count] > 3) {
		// Yes, it contains more than 3 puyos.
		
		// Add current grouping set to set of all groupings.
		[groupings addObject:currentGrouping];
		
	}
	
	//  Release the current grouping set.
	[currentGrouping release];
	currentGrouping = nil;
}

- (void) computeScore {
	// Mark puyos in groupings set as disappearing and increase score.
	for (NSSet *grouping in groupings) {
		for (Puyo *puyo in grouping) {
			score += 10;
			puyo.disappearing = YES;
		}
	}
	
	// Release grouping sets and their contents.
	[groupings removeAllObjects];
	[groupings release];
	groupings = nil;
	[currentGrouping removeAllObjects];
	[currentGrouping release];
	currentGrouping = nil;
}

// This method sets the move cycle ratio according to score
- (void) determineDifficultyIncrease {
	if (score >= 2500 && moveCycleRatio > 20) {
		moveCycleRatio = 20;
		difficulty++;
	}
	else if (score >= 2000 && moveCycleRatio > 25) {
		moveCycleRatio = 25;
		difficulty++;
	}
	else if (score >= 1500 && moveCycleRatio > 30) {
		moveCycleRatio = 30;
		difficulty++;
	}
	else if (score >= 1000 && moveCycleRatio > 35) {
		moveCycleRatio = 35;
		difficulty++;
	}
	else if (score >= 500 && moveCycleRatio > 40) {
		moveCycleRatio = 40;
		difficulty++;
	}
}

- (void) checkForPuyoGroupings:(Puyo *)p1 {
	// Is there a stuck, not disappearing puyo at this spot?
	if (nil != p1 && p1.stuck && !p1.disappearing) {
		// Yes, there is a stuck, not disappearing puyo here
		
		// Is the current grouping set not empty?
		if ([currentGrouping count] > 0) {
			// Current grouping set is not empty.
			
			// Is puyo same type as those in current grouping set?
			Puyo *p2 = [currentGrouping anyObject];
			if ( p2.puyoType == p1.puyoType ) {
				// Yes, it's the same type.
				
				// Add puyo to current grouping set.
				[currentGrouping addObject:p1];
				
			} else {
				// It's of a different type. Current grouping ends here.
				
				// Current grouping set contains more than 3 puyos?
				if ([currentGrouping count] > 3) {
					// Yes, there are more than 3 puyos.
					
					// Add current grouping set to set of all groupings.
					[groupings addObject:currentGrouping];
					
				}
				
				//  Release the current grouping set.
				[currentGrouping release];
				currentGrouping = nil;
				// Create a new current grouping set, and add puyo.
				currentGrouping = [[NSMutableSet alloc] init];
				[currentGrouping addObject:p1];
				
			} // End of if ( p2.puyoType == p1.puyoType )
			
		} else {
			// Current grouping set is empty.
			
			// Add the puyo to the current grouping set.
			[currentGrouping addObject:p1];
			
		} // End of if ([currentGrouping count] > 0)
		
	} else {
		// This position on the board is empty, or puyo isn't stuck or 
		// it's disappearing. Current grouping ends here.
		
		// Current grouping set contains more than 3 puyos?
		if ([currentGrouping count] > 3) {
			// Yes, it contains more than 3 puyos.
			
			// Add current grouping set to set of all groupings.
			[groupings addObject:currentGrouping];
			
		}
		
		//  Release the current grouping set.
		[currentGrouping release];
		currentGrouping = nil;
		
		// Create a new current grouping set.
		currentGrouping = [[NSMutableSet alloc] init];
		
	} // End of if (nil != p1)
}

// This method sweeps through the board and disappears puyos that 
// have been marked as disappearing.
- (void) disappearPuyos {	
	Puyo *puyo = nil;
	
	for (int x = 0; x <= kLastColumn; x++) {
		for (int y = 0; y <= kLastRow; y++) {
			
			puyo = board[x][y];
			
			// Is this block disappearing?
			if (nil != puyo && puyo.disappearing) {
				
				// Is this puyo's opacity greather than 5?
				if (5 < puyo.opacity) {

					// Make disappearing blocks fade out over time.
					puyo.opacity -= 5;
										
				} else {
						
					// Remove puyos with opacity below 5.						
					[self removeChild:puyo cleanup:YES];
					puyo = nil;
					board[x][y] = nil;
						
				}  // End of if (5 < puyo.opacity)

			} // End of if (nil != puyo && puyo.disappearing)
			
		} // End of for y loop.
	} // End of for x loop.
}

// This method sweeps through the board and moves puyos if there is an
// empty spot below them.
- (void) movePuyosDown {	
	Puyo *puyo = nil;
		
	// get new puyos when these puyos can't drop any more
	if ( puyo1.stuck && puyo2.stuck ) {
		[self tryToCreateNewPuyos];
	}
	
	for (int x = kLastColumn; x >= 0; x--) {
		for (int y = kLastRow; y >= 0; y--) {
			
			puyo = board[x][y];
			
			// Is puyo "solid?" i.e. not disappearing?
			if (nil != puyo && !puyo.disappearing) {
				
				// Can this puyo drop down to the next cell?
				if ( kLastRow != y && (nil == board[x][y + 1]) ) {
					
					// Channel Bob Parker: Come on down!
					[self movePuyoDown:puyo];
					puyo.stuck = NO;
					
				} else {
					// This puyo can't drop anymore, it's stuck.
					puyo.stuck = YES;
				}
				
			} // End of if (nil != puyo && !puyo.disappearing)
			
		} // End of for y loop.
	} // End of for x loop.
	
	if (kLastRow == puyo1.boardY) {
		puyo1.stuck = YES;
	}
	if (kLastRow == puyo2.boardY) {
		puyo2.stuck = YES;
	}
}

- (void) updateInfoDisplays {
	static int oldDifficulty = 1;
	static int oldScore = 0;
	
	if (oldDifficulty != difficulty) {
		oldDifficulty = difficulty;
		NSString *tempStr = 
			[[NSString alloc] initWithFormat:@"%01d",difficulty];
		[difficultyLabel setString:tempStr];
		[difficultyLabel draw];
		[tempStr release];
		tempStr = nil;
	}
	
	if (oldScore != score) {
		oldScore = score;
		NSString *tempStr = 
			[[NSString alloc] initWithFormat:@"%05d",score];
		[scoreLabel setString:tempStr];
		[scoreLabel draw];
		[tempStr release];
		tempStr = nil;
	}
}

@end