//
//  AbstractSceneController.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
@class Sprite;

@interface AbstractSceneController : NSObject {
    NSMutableArray *spriteList;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;


- (void)playScene;
- (void)addSprite:(Sprite *)sprite;
- (void)updateScene;

@end
