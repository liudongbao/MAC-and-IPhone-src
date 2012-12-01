//
//  EWSoundListenerObject.m
//  SpaceRocks
//
//  Created by Eric Wing on 8/24/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWSoundListenerObject.h"


@implementation EWSoundListenerObject

@synthesize atOrientation;
@synthesize upOrientation;

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		atOrientation = BBPointMake(0.0f, 1.0f, 0.0f); // looking along Y
		upOrientation = BBPointMake(0.0f, 0.0f, 1.0f); // Z is up
	}
	return self;
}

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
	
	ALfloat orientation_array[6] = {
		atOrientation.x, atOrientation.y, atOrientation.z,
		upOrientation.x, upOrientation.y, upOrientation.z
	};
	alListenerfv(AL_ORIENTATION, orientation_array);
	alListener3f(AL_VELOCITY, objectVelocity.x, objectVelocity.y, objectVelocity.z);

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
