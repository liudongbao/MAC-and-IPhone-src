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

@implementation AbstractSceneController

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView { }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView { }
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView { }

- (void)playScene { 
    glClear(GL_COLOR_BUFFER_BIT);
}

#pragma mark Concrete methods

- (void)addSprite:(Sprite *)sprite {
    if (spriteList == nil)
        spriteList = [NSMutableArray array];
    
    [spriteList addObject:sprite];
}

- (void)updateScene {
    if (spriteList != nil) {
        for (Sprite *sprite in spriteList) {
            if ([sprite isKindOfClass:[EnemySprite class]] && [(EnemySprite *)sprite isMissileActive])
                 [[(EnemySprite *)sprite missile] updateTransforms];
            [sprite updateTransforms];
        }
    }
}

@end
