//
//  Level1SceneController.m
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Level1SceneController.h"
#import "EnemySprite.h"
#import "Explode.h"
#import "SoundEffects.h"
#import "BitmapFont.h"
#import "GameController.h"

#define NUM_ITEMS 12
#define SCORE_POINT CGPointMake(130, 5)
#define LIVES_POINT CGPointMake(300, 5)

@implementation Level1SceneController

- (id) init
{
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}

- (void)initScene {
    [super initScene];
    isGameOver = NO;
    [GameController sharedGameController].currentLives = 3;
    [GameController sharedGameController].currentScore = 0;
    activeEnemies = NUM_ITEMS;
    
    playerSprite = [[PlayerSprite alloc] init];
    leftJoystick = [[ActionItem alloc] initWithImageNamed:@"left_joystick.png"];
    rightJoystick = [[ActionItem alloc] initWithImageNamed:@"right_joystick.png"];
    
    for (int i = 0; i < NUM_ITEMS; i++) {
        int x = 25 * i + 25;
        EnemySprite *sprite = nil;
        
        if (i == 0 || i > 10) {
            sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy3.png"];
            sprite.enemyType = kKamikazeSprite;
            sprite.currentPosition = CGPointMake(x, 95.0f);
        } else if (i % 2 == 0) {
            sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy2.png"];
            sprite.enemyType = kDiagonalSprite;
            sprite.currentPosition = CGPointMake(x, 70.0f); 
        }
        else {
            sprite = [[EnemySprite alloc] initWithImageNamed:@"enemy1.png"];
            sprite.enemyType = kDumbSprite;
            sprite.currentPosition = CGPointMake(x, 45.0f); 
        }
        
        sprite.tag = i;
        sprite.delegate = self;
        [self addSprite:sprite];
    }
    
    fireSprite = [[Sprite alloc] initWithImageNamed:@"fire.png"];
    
    [self addSprite:playerSprite];
    [self addSprite:leftJoystick];
    [self addSprite:rightJoystick];
    [self addSprite:fireSprite];
    
    CGRect spriteBounds = playerSprite.bounds;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    playerSprite.currentPosition = CGPointMake((screenBounds.size.width / 2) - (spriteBounds.size.width / 2), 
                                               (screenBounds.size.height - spriteBounds.size.height - 50));
    
    accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.updateInterval = 0.1;
    accelerometer.delegate = self;
    
    itemStrafing = -1;
    
    font = [[BitmapFont alloc] initWithFontImageNamed:@"fontbitmap.png" controlFile:@"1"];
    
    [self addMessage:[font drawTextAtPoint:@"Score" point:CGPointMake(0, 5)]];
    scoreCharacterArray = [font drawTextAtPoint:@"0" point:SCORE_POINT];
    [self addMessage:scoreCharacterArray];
    [self addMessage:[font drawTextAtPoint:@"Lives" point:CGPointMake(180, 5)]];
    livesCharacterArray = [font drawTextAtPoint:@"3" point:LIVES_POINT];
    [self addMessage:livesCharacterArray];
}


- (void)playScene {
    [super playScene];
    
    for (NSArray *messages in messageList) {
        for (Sprite *sprite in messages) {
            [sprite drawAtPosition:CGPointMake(sprite.bounds.origin.x, sprite.bounds.origin.y)];
        }
    }
    
    if (isGameOver) return;
    
    [leftJoystick drawAtPosition:CGPointMake(10, 445)];
    [rightJoystick drawAtPosition:CGPointMake(74, 445)];
    [fireSprite drawAtPosition:CGPointMake(160.0, 430.0)];
    
    for (EnemySprite *sprite in spriteList) {
        if ([sprite isKindOfClass:[EnemySprite class]]) {
            if (playerSprite.hasBeenShot) {
                sprite.canFireMissile = NO;
                ticks++;
                if (ticks > 240) {
                    ticks = 0;
                    playerSprite.hasBeenShot = NO;
                }
            }
            else
                sprite.canFireMissile = YES;
            
            if (!sprite.canFireMissile && !playerSprite.hasBeenShot)
                sprite.canFireMissile = YES;
            
            if (itemStrafing == -1) {
                itemStrafing = 0;
            }
            if (itemStrafing == sprite.tag) {
                if (sprite.hasBeenShot) {
                    [self strafingFinished];
                    continue;
                }
                if (!sprite.isStrafing && !isGameOver)
                    [sprite startRun:playerSprite.currentPosition];
                else
                    sprite.playersCurrentPosition = playerSprite.currentPosition;
            }
        
            if (!sprite.hasBeenShot)
                [sprite drawPlayer];
            else
                continue;
            
            if (sprite.isMissileActive) {
                if ([self checkForCollisions:sprite.missile]) {
                    sprite.isMissileActive = NO;
                    playerSprite.hasBeenShot = YES;
                    [self resetScene];
                }
            }
            
            if (playerSprite.isMissileActive) {
                if ([self checkForCollisions:sprite]) {
                    playerSprite.isMissileActive = NO;
                    sprite.hasBeenShot = YES;  
                    if (sprite.tag == itemStrafing)
                        [self strafingFinished];
                }
            }
        }
        else if ([sprite isKindOfClass:[PlayerSprite class]])
            if (!sprite.hasBeenShot)
                [sprite drawPlayer];
        else if ([sprite isKindOfClass:[Sprite class]]  && ![sprite isKindOfClass:[PlayerSprite class]])
            [sprite draw];
                  
    }
    
    for (Explode *explode in explosionList) {
        if ([explode isKindOfClass:[Explode class]]) {
            if (!explode.hasAnimationFinished) {
                Sprite *sprite = [explode doAnimation];
                [sprite drawAtPosition:explode.explosionPoint];
            }
        }
    }
    
}

#pragma mark - StrafingFinishedDelegate

- (void)strafingFinished {
    itemStrafing++;
    if (itemStrafing >= NUM_ITEMS)
        itemStrafing = 0;
}

#pragma mark - Collision Detetection

- (BOOL)checkForCollisions:(Sprite *)spriteToCheck {
    if (spriteToCheck.tag == ENEMY_MISSILE) {
        if ([spriteToCheck hasCollidedBoundingBox:playerSprite.bounds]) {
            Explode *explode = [[Explode alloc] initWithPoint:CGPointMake(spriteToCheck.bounds.origin.x, spriteToCheck.bounds.origin.y)];
            [self addExplosion:explode];
            [[SoundEffects sharedSoundEffects] playExplosionEffect];
            return YES;
        }
    }
    else if (playerSprite.isMissileActive && [playerSprite.missile hasCollidedBoundingBox:spriteToCheck.bounds]) {
        Explode *explode = [[Explode alloc] initWithPoint:CGPointMake(spriteToCheck.bounds.origin.x, spriteToCheck.bounds.origin.y)];
        [self addExplosion:explode];
        [[SoundEffects sharedSoundEffects] playExplosionEffect];
        
        if (!firstKill)
            [self checkFirstKillAchieved];
        int points = 0;
        
        if ([(EnemySprite *)spriteToCheck enemyType] == kDumbSprite) 
            points = 10;
        else if ([(EnemySprite *)spriteToCheck enemyType] == kDiagonalSprite)
            points = 20;
        else if ([(EnemySprite *)spriteToCheck enemyType] == kKamikazeSprite)
            points = 30;
        
        [self updateScore:points];
        activeEnemies--;
        
        if (activeEnemies == 0) {
            isGameOver = YES;
            [self addMessage:[font drawTextAtPoint:@"YOU WIN" point:CGPointMake(80, 220)]];
            [self addMessage:[font drawTextAtPoint:@"Tap To Continue" point:CGPointMake(30, 250)]];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)resetScene {
    GameController *controller = [GameController sharedGameController];
    controller.currentLives--;
    int lives = controller.currentLives;
    
    if (lives == 0) {
        isGameOver = YES;  
        [self addMessage:[font drawTextAtPoint:@"GAME OVER" point:CGPointMake(80, 220)]];
        [self addMessage:[font drawTextAtPoint:@"Tap To Continue" point:CGPointMake(30, 250)]];
    }
    
    [self removeMessage:livesCharacterArray];
    livesCharacterArray = [font drawTextAtPoint:[NSString stringWithFormat:@"%d", lives] point:LIVES_POINT];
    [self addMessage:livesCharacterArray];
}

- (void)updateScore:(int)amount {
    GameController *controller = [GameController sharedGameController];
    controller.currentScore += amount;
    
    [self removeMessage:scoreCharacterArray];
    scoreCharacterArray = [font drawTextAtPoint:[NSString stringWithFormat:@"%d", controller.currentScore] point:SCORE_POINT];
    [self addMessage:scoreCharacterArray];
    
}

- (void)checkFirstKillAchieved {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasFirstKillBeenAchieved = [defaults boolForKey:@"FirstKill"];
    
    if (!hasFirstKillBeenAchieved) {
        [defaults setBool:YES forKey:@"FirstKill"];
        [self reportAchievementIdentifier:@"FirstKill" percentComplete:100.0];
        [defaults synchronize];
        firstKill = YES;
    }
}

#pragma mark - touch methods

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isGameOver) return;
    
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    
    if (touchPoint.x > width - (playerSprite.bounds.size.width / 2))
        playerSprite.currentPosition = CGPointMake(width, playerSprite.currentPosition.y);
    else
        playerSprite.currentPosition = CGPointMake(touchPoint.x, playerSprite.currentPosition.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    
    if (isGameOver) return;
    
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
    if (isGameOver) {
        [self sendScoreToGameCenter:[[GameController sharedGameController] currentScore] forCategory:@"score"];
        //[[GameController sharedGameController] sendTweet];
        [[GameController sharedGameController] changeScene:MENU_SCENE];
    }
    
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
    else if (CGRectContainsPoint(CGRectMake(160.0, 430.0, 160.0, 50.0), touchPoint)) {
        [playerSprite fireMissile];
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
