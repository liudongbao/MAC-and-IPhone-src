//
//  EWSoundSourceObject.m
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWSoundSourceObject.h"
#import "OpenALSoundController.h"
#import "EWSoundBufferData.h"

@implementation EWSoundSourceObject

@synthesize sourceID;
@synthesize hasSourceID;
@synthesize audioLooping;
@synthesize pitchShift;


- (id) init
{
	self = [super init];
	if(nil != self)
	{
		audioLooping = AL_FALSE;
		pitchShift = 1.0f;
	}
	return self;
}

- (void) applyState
{
	[super applyState];
	if(NO == self.hasSourceID)
	{
		return;
	}
	if([[OpenALSoundController sharedSoundController] inInterruption])
	{
		return;
	}
	alSourcef(self.sourceID, AL_GAIN, self.gainLevel);
	alSourcei(self.sourceID, AL_LOOPING, self.audioLooping);
	alSourcef(self.sourceID, AL_PITCH, self.pitchShift);
}

- (void) update
{
	[super update];
	[self applyState];
}

- (BOOL) playSound:(EWSoundBufferData*)sound_buffer_data
{
	OpenALSoundController* sound_controller = [OpenALSoundController sharedSoundController];
	ALuint buffer_id = sound_buffer_data.openalDataBuffer;
	ALuint source_id;
	BOOL is_source_available = [sound_controller reserveSource:&source_id];
	if(NO == is_source_available)
	{
		return NO;
	}
	
	self.sourceID = source_id;
	self.hasSourceID = YES;

	alSourcei(source_id, AL_BUFFER, buffer_id);
	[self applyState];
	[sound_controller playSound:source_id];

	return YES;
}

- (void) stopSound
{
	OpenALSoundController* sound_controller = [OpenALSoundController sharedSoundController];
	if(YES == self.hasSourceID)
	{
		[sound_controller stopSound:self.sourceID];
		self.hasSourceID = NO;			
	}
}

/**
 * @note It is possible that the object will be destroyed and removed from the game before this callback is triggered.
 * In that case, this callback will never be invoked.
 * Don't rely too heavily on it.
 */
- (void) soundDidFinishPlaying:(NSNumber*)source_number
{
	if([source_number unsignedIntValue] == self.sourceID)
	{
		self.hasSourceID = NO;
	}
}


@end
