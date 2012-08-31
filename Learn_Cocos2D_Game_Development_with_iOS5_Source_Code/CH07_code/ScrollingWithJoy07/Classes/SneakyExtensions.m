//
//  SneakyExtensions.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "SneakyExtensions.h"


@implementation SneakyButton (Extension)
+(id) button
{
	return [[[SneakyButton alloc] initWithRect:CGRectZero] autorelease];
}

+(id) buttonWithRect:(CGRect)rect
{
	return [[[SneakyButton alloc] initWithRect:rect] autorelease];
}
@end


@implementation SneakyButtonSkinnedBase (Extension)
+(id) skinnedButton
{
	return [[[SneakyButtonSkinnedBase alloc] init] autorelease];
}
@end

@implementation SneakyJoystick (Extension)
+(id) joystickWithRect:(CGRect)rect
{
	return [[[SneakyJoystick alloc] initWithRect:rect] autorelease];
}
@end

@implementation SneakyJoystickSkinnedBase (Extension)
+(id) skinnedJoystick
{
	return [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
}
@end

