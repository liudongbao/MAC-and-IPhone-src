//
//  AbstractSceneController.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
@class Sprite;
@class Explode;

@interface AbstractSceneController : NSObject {
    NSMutableArray *spriteList;
    NSMutableArray *explosionList;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView;

- (void)playScene;
- (void)addSprite:(Sprite *)sprite;
- (void)addExplosion:(Explode *)explode;
- (void)removeExplosion:(Explode *)explode;

- (void)updateScene;

- (BOOL)checkForCollisions:(Sprite *)spriteToCheck;

@end
