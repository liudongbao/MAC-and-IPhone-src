//
//  InputLayer.h
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// SneakyInput headers
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"

#import "SneakyExtensions.h"

@interface InputLayer : CCLayer 
{
	SneakyButton* fireButton;
	SneakyJoystick* joystick;
	
	ccTime totalTime;
	ccTime nextShotTime;
}

@end
