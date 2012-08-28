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
@synthesize missile;
@synthesize isMissileActive;
@synthesize hasBeenShot;

- (id)init {
    return [self initWithImageNamed:@"ship.png"];
}

- (void)drawPlayer {
    if (isMoving)
        [self movePlayer:amountToMove];
    
    if (isMissileActive) {
        missile_y-= 5;
        if (missile_y < 0)
            isMissileActive = NO;
        
        float x = self.missile.bounds.origin.x;
        
        [self.missile drawAtPosition:CGPointMake(x, missile_y)];
    }
    
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

- (void)fireMissile {
    if (isMissileActive) return;
    
    isMissileActive = YES;
    if (self.missile == nil) {
        self.missile = [[Sprite alloc] initWithImageNamed:@"player_missile.png"];
        self.missile.tag = PLAYER_MISSILE;
    }
    [self.missile drawAtPosition:currentPosition];
    missile_y = currentPosition.y;
}

@end
