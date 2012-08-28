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
    }
}

@end
