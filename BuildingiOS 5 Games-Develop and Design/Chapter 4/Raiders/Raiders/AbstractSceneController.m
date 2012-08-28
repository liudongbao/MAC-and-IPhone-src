//
//  AbstractSceneController.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "AbstractSceneController.h"
#import "Sprite.h"

@implementation AbstractSceneController

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView { }

- (void)playScene { }

#pragma mark Concrete methods

- (void)addSprite:(Sprite *)sprite {
    if (spriteList == nil)
        spriteList = [NSMutableArray array];
    
    [spriteList addObject:sprite];
}

- (void)updateScene {
    if (spriteList != nil) {
        for (Sprite *sprite in spriteList) {
            [sprite updateTransforms];
        }
    }
}

@end
