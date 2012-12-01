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
@synthesize referenceDistance;
@synthesize maxDistance;
@synthesize atDirection;
@synthesize coneInnerAngle;
@synthesize coneOuterAngle;
@synthesize coneOuterGain;
@synthesize sourceRelative;
@synthesize positionalDisabled;

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		audioLooping = AL_FALSE;
		pitchShift = 1.0f;
		rolloffFactor = 1.0; // 0.0 disables attenuation
		referenceDistance = 1.0;
		maxDistance = FLT_MAX;
		atDirection = BBPointMake(0.0, 0.0, 0.0);
		coneInnerAngle = 360.0;
		coneOuterAngle = 360.0;
		coneOuterGain = 0.0;
		sourceRelative = AL_FALSE;
		positionalDisabled = NO;
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
	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"alSourcef AL_GAIN: %s", alGetString(al_error));
	}
	alSourcei(self.sourceID, AL_LOOPING, self.audioLooping);
	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"alSourcei AL_LOOPING: %s", alGetString(al_error));
	}
	alSourcef(self.sourceID, AL_PITCH, self.pitchShift);

	if(YES == positionalDisabled)
	{
		// Disable positional sound

		alSourcei(sourceID, AL_SOURCE_RELATIVE, AL_TRUE); // set to relative positioning so we can set everything to 0
		alSourcef(sourceID, AL_ROLLOFF_FACTOR, 0.0); // 0 to disable attenuation 
		alSourcef(sourceID, AL_REFERENCE_DISTANCE, referenceDistance); // doesn't matter
		alSourcef(sourceID, AL_MAX_DISTANCE, maxDistance); // doesn't matter
		
		alSource3f(sourceID, AL_POSITION, 0.0, 0.0, 0.0);
		alSource3f(sourceID, AL_DIRECTION, 0.0, 0.0, 0.0);
		alSourcef(sourceID, AL_CONE_INNER_ANGLE, 360.0);
		alSourcef(sourceID, AL_CONE_OUTER_ANGLE, 360.0);
		alSourcef(sourceID, AL_CONE_OUTER_GAIN, 0.0);
		alSource3f(sourceID, AL_VELOCITY, 0.0, 0.0, 0.0);		
	}
	else
	{
		alSourcei(sourceID, AL_SOURCE_RELATIVE, sourceRelative); // set to relative positioning so we can set everything to 0
		alSourcef(sourceID, AL_ROLLOFF_FACTOR, rolloffFactor);
		alSourcef(sourceID, AL_REFERENCE_DISTANCE, referenceDistance);
		alSourcef(sourceID, AL_MAX_DISTANCE, maxDistance);
		
		alSource3f(sourceID, AL_POSITION, objectPosition.x, objectPosition.y, objectPosition.z);
		alSource3f(sourceID, AL_DIRECTION, atDirection.x, atDirection.y, atDirection.z);
		alSourcef(sourceID, AL_CONE_INNER_ANGLE, coneInnerAngle);
		alSourcef(sourceID, AL_CONE_OUTER_ANGLE, coneOuterAngle);
		alSourcef(sourceID, AL_CONE_OUTER_GAIN, coneOuterGain);
		alSource3f(sourceID, AL_VELOCITY, objectVelocity.x, objectVelocity.y, objectVelocity.z);
		
	}

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
	ALenum al_error;
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
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alSourcei AL_BUFFER: %s", alGetString(al_error));
		}
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



- (BOOL) playStream:(EWStreamBufferData*)stream_buffer_data
{
	OpenALSoundController* sound_controller = [OpenALSoundController sharedSoundController];
	if(sound_controller.inInterruption)
	{
		NSInvocation* an_invocation = CreateAutoreleasedInvocation(self, @selector(playStream:), stream_buffer_data, nil);
		[sound_controller queueEvent:an_invocation];
		// Yes or No?
		return YES;
	}
	else
	{
		ALuint source_id;
		BOOL is_source_available = [sound_controller reserveSource:&source_id];
		if(NO == is_source_available)
		{
			return NO;
		}
		
		self.sourceID = source_id;
		self.hasSourceID = YES;
		[self applyState];
		[sound_controller playStream:source_id streamBufferData:stream_buffer_data];
	}
	return YES;
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


- (void) setSourceRelative:(ALboolean)source_relative
{
	sourceRelative = source_relative;
	[self applyState];
}

- (void) setPositionalDisabled:(BOOL)positional_disabled
{
	positionalDisabled = positional_disabled;
	[self applyState];
}

@end
