//
//  EWSoundListenerObject.m
//  SpaceRocks
//
//  Created by Eric Wing on 8/24/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWSoundListenerObject.h"


@implementation EWSoundListenerObject

- (void) applyState
{
	ALenum al_error;

	[super applyState];

	if([[OpenALSoundController sharedSoundController] inInterruption])
	{
		return;
	}
	alListenerf(AL_GAIN, gainLevel);
	alListener3f(AL_POSITION, objectPosition.x, objectPosition.y, objectPosition.z);

	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"Error setting listener: %s", alGetString(al_error));
	}
}

- (void) update
{
	[super update];
	[self applyState];
}

@end
