//
//  GameScene.m
//  PuyoClone
//
//  Created by PJ Cabrera on 5/8/09.
//  Copyright 2009 PJ Cabrera. All rights reserved.
//

#import "GameScene.h"
#import "GameLogicLayer.h"

@implementation GameScene

- (id) init {
    self = [super init];
    if (self != nil) {
		Sprite *bg = [Sprite spriteWithFile:@"background.png"];
		[bg setPosition:ccp(160, 240)];
		[self addChild:bg z:0];
		
        Layer *layer = [GameLogicLayer node];
		[self addChild:layer z:1];
    }
    return self;
}

- (void) dealloc {
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end
