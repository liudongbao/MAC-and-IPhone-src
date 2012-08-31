//
//  SneakyExtensions.h
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

// SneakyInput headers
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"


@interface SneakyButton (Extension)
+(id) button;
+(id) buttonWithRect:(CGRect)rect;
@end

@interface SneakyButtonSkinnedBase (Extension)
+(id) skinnedButton;
@end

@interface SneakyJoystick (Extension)
+(id) joystickWithRect:(CGRect)rect;
@end

@interface SneakyJoystickSkinnedBase (Extension)
+(id) skinnedJoystick;
@end

