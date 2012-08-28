//
//  Level1SceneController.m
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Level1SceneController.h"
#import "EnemySprite.h"

#define NUM_ITEMS 12

@implementation Level1SceneController

- (id) init
{
	self = [super init];
	if (self != nil) {
		playerSprite = [[PlayerSprite alloc] init];
        leftJoystick = [[ActionItem alloc] initWithImageNamed:@"left_joystick.png"];
        rightJoystick = [[ActionItem alloc] initWithImageNamed:@"right_joystick.png"];
        
        for (int i = 0; i < NUM_ITEMS; i++) {
            int x = 25 * i + 25;
            EnemySprite *sprite = nil;
            
            if (i == 0 || i > 10) {
                sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy3.png"];
                sprite.enemyType = kKamikazeSprite;
                sprite.currentPosition = CGPointMake(x, 75.0f);
            } else if (i % 2 == 0) {
                sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy2.png"];
                sprite.enemyType = kDiagonalSprite;
                sprite.currentPosition = CGPointMake(x, 50.0f); 
            }
            else {
                sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy1.png"];
                sprite.enemyType = kDumbSprite;
                sprite.currentPosition = CGPointMake(x, 25.0f); 
            }
                                   
            sprite.tag = i;
            sprite.delegate = self;
            [self addSprite:sprite];
        }
        
        [self addSprite:playerSprite];
        [self addSprite:leftJoystick];
        [self addSprite:rightJoystick];
        
        
        CGRect spriteBounds = playerSprite.bounds;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        playerSprite.currentPosition = CGPointMake((screenBounds.size.width / 2) - (spriteBounds.size.width / 2), 
                                                   (screenBounds.size.height - spriteBounds.size.height - 50));
        
        accelerometer = [UIAccelerometer sharedAccelerometer];
        accelerometer.updateInterval = 0.1;
        accelerometer.delegate = self;
        
        itemStrafing = -1;
	}
	return self;
}

- (void)playScene {
    [super playScene];
    [leftJoystick drawAtPosition:CGPointMake(10, 445)];
    [rightJoystick drawAtPosition:CGPointMake(74, 445)];
    
    for (EnemySprite *sprite in spriteList) {
        if ([sprite isKindOfClass:[EnemySprite class]]) {
            if (itemStrafing == -1) {
                itemStrafing = 0;
            }
            if (itemStrafing == sprite.tag)
                if (!sprite.isStrafing)
                    [sprite startRun:playerSprite.currentPosition];
                else
                    sprite.playersCurrentPosition = playerSprite.currentPosition;
        
            [sprite drawPlayer];
            
        }
        else if ([sprite isKindOfClass:[PlayerSprite class]])
            [sprite drawPlayer];
    }
    
}

#pragma mark - StrafingFinishedDelegate

- (void)strafingFinished {
    itemStrafing++;
    if (itemStrafing >= NUM_ITEMS)
        itemStrafing = 0;
}

#pragma mark - touch methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    
    if (touchPoint.x > width - (playerSprite.bounds.size.width / 2))
        playerSprite.currentPosition = CGPointMake(width, playerSprite.currentPosition.y);
    else
        playerSprite.currentPosition = CGPointMake(touchPoint.x, playerSprite.currentPosition.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    if ([leftJoystick hasBeenTapped:touchPoint]) {
        [leftJoystick tapAction:@selector(moveLeft) target:self];
    }
    else if ([rightJoystick hasBeenTapped:touchPoint]) {
        [rightJoystick tapAction:@selector(moveRight) target:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    if ([leftJoystick hasBeenTapped:touchPoint]) {
        if (playerSprite.isMoving)
            [leftJoystick tapAction:@selector(stopMoving) target:self];

    }
    else if ([rightJoystick hasBeenTapped:touchPoint]) {
        if (playerSprite.isMoving)
            [rightJoystick tapAction:@selector(stopMoving) target:self];
    } 
}

- (void)moveLeft {
    playerSprite.isMoving = YES;
    [playerSprite movePlayer:-5];
}

- (void)moveRight {
    playerSprite.isMoving = YES;
    [playerSprite movePlayer:5];
}

- (void)stopMoving {
    playerSprite.isMoving = NO;
}

#pragma mark - accelerometer methods

#define kThreshold 0.1

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if (acceleration.x > kThreshold)
        [playerSprite movePlayer:5];
    if (acceleration.x < kThreshold * -1)
        [playerSprite movePlayer:-5];
}

@end
