//
//  PlayerSprite.m
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "PlayerSprite.h"

@implementation PlayerSprite

@synthesize isMoving;

- (id)init {
    return [self initWithImageNamed:@"ship.png"];
}

- (void)drawPlayer {
    if (isMoving)
        [self movePlayer:amountToMove];
    
    [self drawAtPosition:currentPosition];
}

- (CGPoint)currentPosition {
    return currentPosition;
}
- (void)setCurrentPosition:(CGPoint)currentPos {
    currentPosition = currentPos;
    
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (currentPosition.x > screenWidth - self.width)
        currentPosition.x = screenWidth - self.width;
    else if (currentPosition.x <= 0)
        currentPosition.x = 0;
}

- (void)movePlayer:(int)pixelsToMove {
    if (isMoving)
        amountToMove = pixelsToMove;
    
    self.currentPosition = CGPointMake(currentPosition.x + pixelsToMove, currentPosition.y);
}

@end
