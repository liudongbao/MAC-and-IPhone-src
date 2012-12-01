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

// va_args must be objects and not primitives
// list must be nil terminated
static NSInvocation* CreateAutoreleasedInvocation(id target_object, SEL the_selector, ...)
{
	NSMethodSignature* method_signature;
	NSInvocation* an_invocation;
	
	method_signature = [[target_object class] instanceMethodSignatureForSelector:the_selector];
	an_invocation = [NSInvocation invocationWithMethodSignature:method_signature];
	[an_invocation setSelector:the_selector];
	[an_invocation setTarget:target_object];
	
	id current_object;
	NSInteger argument_index = 2; // self and _cmd are 0 and 1
	va_list arg_list;
	va_start(arg_list, the_selector); // start after the argument "the_selector"
	while( nil != (current_object = va_arg(arg_list, id)) )
	{
		[an_invocation setArgument:&current_object atIndex:argument_index];
		argument_index++;
	}
	va_end(arg_list);
	
	 // It's possible the target_object or arguments could be released
	 // by the time this method is invoked, so retain everything.
	[an_invocation retainArguments];
	return an_invocation;
}

@implementation EWSoundSourceObject

@synthesize sourceID;
@synthesize hasSourceID;
@synthesize audioLooping;
@synthesize pitchShift;
@synthesize rolloffFactor;
@synthesize atDirection;
@synthesize coneInnerAngle;
@synthesize coneOuterAngle;
@synthesize coneOuterGain;

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		audioLooping = AL_FALSE;
		pitchShift = 1.0f;
		rolloffFactor = 0.0; // 0.0 disables attenuation
		atDirection = BBPointMake(0.0, 0.0, 0.0);
		coneInnerAngle = 360.0;
		coneOuterAngle = 360.0;
		coneOuterGain = 0.0;
	}
	return self;
}

- (void) applyState
{
	ALenum al_error;

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

	// I need to set the rolloff factor to disable attenuation because alDistanceModel(AL_NONE) seems broken.
	alSourcef(sourceID, AL_ROLLOFF_FACTOR, rolloffFactor);

	alSource3f(sourceID, AL_POSITION, objectPosition.x, objectPosition.y, objectPosition.z);
	alSource3f(sourceID, AL_DIRECTION, atDirection.x, atDirection.y, atDirection.z);
	alSourcef(sourceID, AL_CONE_INNER_ANGLE, coneInnerAngle);
	alSourcef(sourceID, AL_CONE_OUTER_ANGLE, coneOuterAngle);
	alSourcef(sourceID, AL_CONE_OUTER_GAIN, coneOuterGain);
	alSource3f(sourceID, AL_VELOCITY, objectVelocity.x, objectVelocity.y, objectVelocity.z);
	al_error = alGetError();
	if(al_error != AL_NO_ERROR)
	{
		NSLog(@"Error setting source id:%d, %s", self.sourceID, alGetString(al_error));
	}

}

- (void) update
{
	[super update];
	[self applyState];
}

- (BOOL) playSound:(EWSoundBufferData*)sound_buffer_data
{
	OpenALSoundController* sound_controller = [OpenALSoundController sharedSoundController];
	if(sound_controller.inInterruption)
	{
		NSInvocation* an_invocation = CreateAutoreleasedInvocation(self, @selector(playSound:), sound_buffer_data, nil);
		[sound_controller queueEvent:an_invocation];
		// Yes or No?
		return YES;
	}
	else
	{
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
	}
	return YES;
}

- (void) stopSound
{
	OpenALSoundController* sound_controller = [OpenALSoundController sharedSoundController];
	if(sound_controller.inInterruption)
	{
		NSInvocation* an_invocation = CreateAutoreleasedInvocation(self, @selector(stopSound), nil);
		[sound_controller queueEvent:an_invocation];		
	}
	else
	{
		if(YES == self.hasSourceID)
		{
			[sound_controller stopSound:self.sourceID];
			self.hasSourceID = NO;			
		}
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
