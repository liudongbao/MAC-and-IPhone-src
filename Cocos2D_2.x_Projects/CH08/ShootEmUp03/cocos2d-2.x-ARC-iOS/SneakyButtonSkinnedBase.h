//
//  SneakyButtonSkinnedBase.h
//  SneakyInput
//
//  Created by Nick Pannuto on 2/19/10.
//  Copyright 2010 Sneakyness, llc.. All rights reserved.
//

#import "cocos2d.h"

@class SneakyButton;

@interface SneakyButtonSkinnedBase : CCSprite {
	CCSprite *defaultSprite;
	CCSprite *activatedSprite;
	CCSprite *disabledSprite;
	CCSprite *pressSprite;
	SneakyButton *button;
}

@property (nonatomic) CCSprite *defaultSprite;
@property (nonatomic) CCSprite *activatedSprite;
@property (nonatomic) CCSprite *disabledSprite;
@property (nonatomic) CCSprite *pressSprite;

@property (nonatomic) SneakyButton *button;

@end
