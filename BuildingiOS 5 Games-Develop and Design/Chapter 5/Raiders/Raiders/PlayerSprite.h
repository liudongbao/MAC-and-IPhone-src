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
}

@property (nonatomic, assign) CGPoint currentPosition;
@property (nonatomic, assign) BOOL isMoving;

- (CGPoint)currentPosition;
- (void)setCurrentPosition:(CGPoint)currentPos;

- (void)drawPlayer;
- (void)movePlayer:(int)pixelsToMove;

@end
