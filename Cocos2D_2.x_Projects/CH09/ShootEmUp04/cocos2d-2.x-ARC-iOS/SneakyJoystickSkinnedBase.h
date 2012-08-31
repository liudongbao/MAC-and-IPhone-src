//
//  SneakyJoystickSkinnedBase.h
//  SneakyJoystick
//
//  Created by CJ Hanson on 2/18/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

#import "cocos2d.h"

@class SneakyJoystick;

@interface SneakyJoystickSkinnedBase : CCSprite {
	CCSprite *backgroundSprite;
	CCSprite *thumbSprite;
	SneakyJoystick *joystick;
}

@property (nonatomic) CCSprite *backgroundSprite;
@property (nonatomic) CCSprite *thumbSprite;
@property (nonatomic) SneakyJoystick *joystick;

- (void) updatePositions;

@end
