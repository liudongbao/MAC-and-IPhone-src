//
//  Puyo.m
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "Puyo.h"

@interface Puyo (private)

- (void) initializeDefaultValues;
- (void) redrawPositionOnBoard;

@end

@implementation Puyo

@synthesize puyoType;
@synthesize stuck;
@synthesize boardX;
@synthesize boardY;
@synthesize disappearing;

+ (Puyo *) newPuyo {
	NSString *filename = nil, *color = nil;
	Puyo *temp = nil;
	
	int puyoType = random() % 4;
	
	switch (puyoType) {
		case 0:
			color = @"blue";
			break;
		case 1:
			color = @"red";
			break;
		case 2:
			color = @"yellow";
			break;
		case 3:
			color = @"green";
			break;
		default:
			color = nil;
			break;
	}

	if (color) {
		filename = 
			[[NSString alloc] 
			 initWithFormat:@"block_%@.pvr", color];
		temp = [self spriteWithFile:filename];
		[filename release];

		[temp initializeDefaultValues];
		[temp setPuyoType: puyoType];
	}
	return temp;
}

- (void) initializeDefaultValues {
	[self setTransformAnchor: ccp(0,0)];
	[self setPosition: ccp(0,0)];
	[self setOpacity: 255];
	[self setStuck: NO];
	[self setDisappearing: NO];
	[self setBoardX: 0];
	[self setBoardY: 0];
}

- (void) redrawPositionOnBoard {
	[self setPosition: COMPUTE_X_Y(boardX, boardY)];
}

- (void) moveRight {
	boardX += 1;
	[self redrawPositionOnBoard];
}

- (void) moveLeft {
	boardX -= 1;
	[self redrawPositionOnBoard];
}

- (void) moveDown {
	boardY += 1;
	[self redrawPositionOnBoard];
}

- (void) moveUp {
	boardY -= 1;
	[self redrawPositionOnBoard];
}

@end
