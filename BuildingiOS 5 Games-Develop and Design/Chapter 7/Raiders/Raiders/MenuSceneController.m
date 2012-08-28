//
//  MenuSceneController.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "MenuSceneController.h"
#import "Sprite.h"
#import "GameController.h"
#import "ActionItem.h"

@implementation MenuSceneController

@synthesize playButton;

- (id) init
{
	self = [super init];
	if (self != nil) {
		playButton = [[ActionItem alloc] initWithImageNamed:@"play"];
        background = [[Sprite alloc] initWithImageNamed:@"background2"];
        [self addSprite:playButton];
        [self addSprite:background];
	}
	return self;
}

- (void)playScene {
    [super playScene];
    [background drawAtPosition:CGPointMake(0.0f, 0.0f)];
    [playButton drawAtPosition:CGPointMake(10.0f, 410.0f)];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    for (ActionItem *item in spriteList) {
        if ([item isKindOfClass:[ActionItem class]] && [item hasBeenTapped:(touchPoint)]) {
            [item tapAction:@selector(gotoLevel1Scene) target:self];
        }
    }
}

- (void)gotoLevel1Scene {
    [[GameController sharedGameController] changeScene:LEVEL1_SCENE];
}

@end
