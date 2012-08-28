//
//  AbstractSceneController.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "AbstractSceneController.h"
#import "Sprite.h"
#import "EnemySprite.h"
#import "Explode.h"

#import <GameKit/GKScore.h>
#import <GameKit/GKAchievement.h>


@implementation AbstractSceneController

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView { }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView { }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView { }
- (BOOL)checkForCollisions:(Sprite *)spriteToCheck { return NO; }

- (void)playScene { 
    glClear(GL_COLOR_BUFFER_BIT);
}

#pragma mark Concrete methods

- (void)addSprite:(Sprite *)sprite {
    if (spriteList == nil)
        spriteList = [NSMutableArray array];
    
    [spriteList addObject:sprite];
}

- (void)addExplosion:(Explode *)explode {
    if (explosionList == nil)
        explosionList = [NSMutableArray array];
    
    [explosionList addObject:explode];
}

- (void)removeExplosion:(Explode *)explode {
    if (explosionList != nil)
        [explosionList removeObject:explode];
}

- (void)addMessage:(NSArray *)message {
    if (messageList == nil)
        messageList = [NSMutableArray array];
    
    [messageList addObject:message];
    
}

- (void)removeMessage:(NSArray *)message {
    if (messageList != nil)
        [messageList removeObject:message];
}

- (void)initScene {
    messageList = nil;
    explosionList = nil;
    spriteList = nil;
}

- (void)updateScene {
    if (spriteList != nil) {
        for (Sprite *sprite in spriteList) {
            if ([sprite isKindOfClass:[EnemySprite class]] && [(EnemySprite *)sprite isMissileActive])
                 [[(EnemySprite *)sprite missile] updateTransforms];
            else if ([sprite isKindOfClass:[PlayerSprite class]] && [(PlayerSprite *)sprite isMissileActive])
                [[(PlayerSprite *)sprite missile] updateTransforms];
            
            [sprite updateTransforms];
        }
        
        for (int i = 0; i < explosionList.count; i++) {
            Explode *explode = [explosionList objectAtIndex:i];
            if ([explode isKindOfClass:[Explode class]]) {
                if (!explode.hasAnimationFinished) {
                    Sprite *sprite = [explode currentSprite];
                    [sprite updateTransforms];
                }
                else {
                    [self removeExplosion:explode];
                }
            }
        }
        
        for (NSArray *messages in messageList) {
            for (Sprite *sprite in messages) {
                [sprite updateTransforms];
            }
        }
    }
}

- (void)sendScoreToGameCenter:(int64_t)score forCategory:(NSString *)category {
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSData *scoreData = [NSKeyedArchiver archivedDataWithRootObject:scoreReporter];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:scoreData forKey:@"lastFailedScore"];
            [defaults synchronize];
            
        }
    }];
}

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent {
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement) {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
             if (error != nil) {
                 // Retain the achievement object and try again later (not shown).
             }
         }];
    }
}

@end
