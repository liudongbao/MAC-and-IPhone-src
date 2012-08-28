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

@implementation MenuSceneController

@synthesize sprite;
@synthesize background;

- (id) init
{
	self = [super init];
	if (self != nil) {
		sprite = [[Sprite alloc] initWithImageNamed:@"play"];
        background = [[Sprite alloc] initWithImageNamed:@"background2"];
        [self addSprite:sprite];
        [self addSprite:background];
	}
	return self;
}

- (void)playScene {
    [background drawAtPosition:CGPointMake(0.0f, 0.0f)];
    [sprite drawAtPosition:CGPointMake(10.0f, 410.0f)];
}

@end
