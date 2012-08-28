//
//  PlayerSprite.h
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Sprite.h"

@interface PlayerSprite : Sprite {
    CGPoint currentPosition;
    int amountToMove;
    
    BOOL isMissileActive;
    float missile_y;
}

@property (nonatomic, assign) CGPoint currentPosition;
@property (nonatomic, assign) BOOL isMoving;

@property (assign) BOOL isMissileActive;
@property (retain) Sprite *missile;

@property (assign) BOOL hasBeenShot;

- (CGPoint)currentPosition;
- (void)setCurrentPosition:(CGPoint)currentPos;

- (void)drawPlayer;
- (void)movePlayer:(int)pixelsToMove;

- (void)fireMissile;

@end
