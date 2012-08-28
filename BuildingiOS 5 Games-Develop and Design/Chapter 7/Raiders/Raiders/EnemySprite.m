//
//  EnemySprite.m
//  Raiders
//
//  Created by James Sugrue on 27/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "EnemySprite.h"
#include <math.h>

@implementation EnemySprite

@synthesize isStrafing;

@synthesize delegate;
@synthesize enemyType;

@synthesize playersCurrentPosition;

- (void)startRun:(CGPoint)playersPosition {
    startPoint = currentPosition;
    
    if (!kDiagonalSprite)
        endPoint = playersPosition;
    else {
        endPoint = CGPointMake(160.0f, 300.0f);
    }
    startTime = [NSDate timeIntervalSinceReferenceDate];
    isStrafing = YES;
}

- (void)drawPlayer {
    if (isStrafing) {
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        if ((now - startTime > 1.2 && enemyType == kDumbSprite) 
            || (endPoint.y <= currentPosition.y && enemyType == kDiagonalSprite && !isReturning)
            || (endPoint.y >= currentPosition.y && enemyType == kDiagonalSprite && isReturning)
            || ((now - startTime > 3.0 && enemyType == kKamikazeSprite) || (currentPosition.y > 430))) {
            
            if (!isReturning) {
                isReturning = YES;
                endPoint = startPoint;
                startPoint = currentPosition;
                startTime = [NSDate timeIntervalSinceReferenceDate];
                if (!isMissileActive)
                    [self fireMissile];
            } else 
                if (isReturning) {
                    isStrafing = NO;
                    isReturning = NO;
                    currentPosition = endPoint;
                    [[self delegate] strafingFinished];
                }
        }
        else {
            self.currentPosition = [self calculatePathAtTime:now - startTime];
        }
    }
    
    if (isMissileActive) {
        missile_y+= 5;
        if (missile_y > 480)
            isMissileActive = NO;
        
        float x = self.missile.bounds.origin.x;
        
        [self.missile drawAtPosition:CGPointMake(x, missile_y)];
    }
    else if (enemyType == kDiagonalSprite && isStrafing) {
        [self checkShouldFireMissile];
    }
    
    [self drawAtPosition:currentPosition];
}

#pragma mark - Calculate Paths for Strafing Runs

- (CGPoint)calculatePathAtTime:(double)time {
    switch (self.enemyType) {
        case kDumbSprite:
            return [self calcForDumbSprite:time];            
        case kDiagonalSprite:
            return [self calcForDiagSprite];
        case kKamikazeSprite:
            return [self calcDirectPath];
        default:
            return CGPointZero;
    }
}

- (CGPoint)calcDirectPath {
    
    float distanceAway = currentPosition.x - playersCurrentPosition.x;
    
    float distanceToMove = ABS(distanceAway) / 10.0f;
    
    if (distanceAway < 0)
        currentPosition.x += distanceToMove;
    else
        currentPosition.x -= distanceToMove;
    
    return CGPointMake(currentPosition.x, currentPosition.y += 2);
}

#define Velocity 10.0f

- (CGPoint)calcForDumbSprite:(double)time {
    float x = currentPosition.x; 
    
    float y = 0;
    if (!isReturning)
        y = currentPosition.y + Velocity * time;
    else
        y = currentPosition.y - Velocity * time;
    
    
    return CGPointMake(x, y);
}

- (CGPoint)calcForDiagSprite {
    float y = 0;
    if (!isReturning)
        y = ABS([self calcYForLineEquation]);
    else
        y = [self calcYForLineEquation];
    
    return CGPointMake(currentPosition.x, y);
}

- (float)calcYForLineEquation {
    //calulate the slope from (y2 - y1) / (x2 - x1)
    float m = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    
    if ((m < 0 || isReturning) && startPoint.x > endPoint.x)
        currentPosition.x--;
    else
        currentPosition.x++;
    
    //calculate b for y = mx + b
    float b = startPoint.y - m * startPoint.x;
    //calculate y 
    float y = m * currentPosition.x + b;
    
    return y;
}

#pragma mark - Missile 

- (void)fireMissile {
    isMissileActive = YES;
    if (self.missile == nil) {
        if (enemyType == kDiagonalSprite)
            self.missile = [[Sprite alloc] initWithImageNamed:@"missile2.png"];
        else if (enemyType == kDumbSprite)
            self.missile = [[Sprite alloc] initWithImageNamed:@"missile1.png"];
        
        self.missile.tag = ENEMY_MISSILE;
    }
    [self.missile drawAtPosition:currentPosition];
    missile_y = currentPosition.y;
}

- (void)checkShouldFireMissile {
    if (playersCurrentPosition.x < currentPosition.x + self.width + 15 &&
        playersCurrentPosition.x > currentPosition.x - 15 &&
        playersCurrentPosition.y < currentPosition.y + 150
        ) {
        [self fireMissile];
    }
}

@end
