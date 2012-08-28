//
//  EnemySprite.h
//  Raiders
//
//  Created by James Sugrue on 27/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Sprite.h"
#import "PlayerSprite.h"

@protocol StrafingFinishedDelegate<NSObject>

- (void)strafingFinished;

@end

@interface EnemySprite : PlayerSprite {
    BOOL isStrafing;
    CGPoint startPoint;
    CGPoint endPoint;
    NSTimeInterval startTime;
    
    BOOL isReturning;
    
//    BOOL isMissileActive;
//    float missile_y;
}

@property (readonly) BOOL isStrafing;


@property (retain) id<StrafingFinishedDelegate> delegate;
@property (assign) EnemyTypes enemyType;


@property (assign) CGPoint playersCurrentPosition;

- (void)startRun:(CGPoint)playersPosition;
- (CGPoint)calculatePathAtTime:(double)time;

- (CGPoint)calcForDumbSprite:(double)time;
- (CGPoint)calcForDiagSprite;
- (float)calcYForLineEquation;
- (CGPoint)calcDirectPath;

- (void)checkShouldFireMissile;

@end
