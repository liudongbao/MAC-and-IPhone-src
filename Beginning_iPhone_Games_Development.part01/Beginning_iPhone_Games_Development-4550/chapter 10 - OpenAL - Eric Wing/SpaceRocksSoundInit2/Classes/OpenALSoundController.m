//
//  OpenALSoundController.m
//  SpaceRocks
//
//  Created by Eric Wing on 7/11/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "OpenALSoundController.h"



#include "AudioSessionSupport.h"
#include "OpenALSupport.h"

static void MyInterruptionCallback(void* user_data, UInt32 interruption_state)
{
	OpenALSoundController* openal_sound_controller = (OpenALSoundController*)user_data;
	if(kAudioSessionBeginInterruption == interruption_state)
	{
		alcSuspendContext(openal_sound_controller.openALContext);
		alcMakeContextCurrent(NULL);
	}
	else if(kAudioSessionEndInterruption == interruption_state)
	{
		OSStatus the_error = AudioSessionSetActive(true);
		if(noErr != the_error)
		{
			printf("Error setting audio session active! %d\n", the_error);
		}
		alcMakeContextCurrent(openal_sound_controller.openALContext);
		alcProcessContext(openal_sound_controller.openALContext);
	}
}

@implementation OpenALSoundController

@synthesize openALDevice;
@synthesize openALContext;
@synthesize outputSource1;
@synthesize outputSource2;
@synthesize outputSource3;
@synthesize laserOutputBuffer;
@synthesize explosion1OutputBuffer;
@synthesize explosion2OutputBuffer;
@synthesize thrustOutputBuffer;


// Singleton accessor.  this is how you should ALWAYS get a reference
// to the scene controller.  Never init your own. 
+ (OpenALSoundController*) sharedSoundController
{
	static OpenALSoundController* shared_sound_controller;
	@synchronized(self)
	{
		if(nil == shared_sound_controller)
		{
			shared_sound_controller = [[OpenALSoundController alloc] init];
		}
		return shared_sound_controller;
	}
	return shared_sound_controller;
}

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		// Audio Session queries must be made after the session is setup
		InitAudioSession(kAudioSessionCategory_AmbientSound, MyInterruptionCallback, self);
		[self initOpenAL];
		
	}
	return self;
}

- (void) initOpenAL
{
	openALDevice = alcOpenDevice(NULL);
	if(openALDevice != NULL)
	{
		// Use the Apple extension to set the mixer rate
		alcMacOSXMixerOutputRate(22050.0);

		// Create a new OpenAL Context
		// The new context will render to the OpenAL Device just created 
		openALContext = alcCreateContext(openALDevice, 0);
		if(openALContext != NULL)
		{
			// Make the new context the Current OpenAL Context
			alcMakeContextCurrent(openALContext);
		}
		else
		{
			NSLog(@"Error, could not create audio context.");
			return;
		}
	}
	else
	{
		NSLog(@"Error, could not get audio device.");
		return;
	}
	
	alGenSources(1, &outputSource1);
	alGenSources(1, &outputSource2);
	alGenSources(1, &outputSource3);
	alGenBuffers(1, &laserOutputBuffer);
	alGenBuffers(1, &explosion1OutputBuffer);
	alGenBuffers(1, &explosion2OutputBuffer);
	alGenBuffers(1, &thrustOutputBuffer);

	ALsizei data_size;
	ALenum al_format;
	ALsizei sample_rate;
	NSURL* file_url;

	file_url = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"laser1" ofType:@"wav"]];
	laserPcmData = MyGetOpenALAudioDataAll((CFURLRef)file_url, &data_size, &al_format, &sample_rate);
	alBufferDataStatic(laserOutputBuffer, al_format, laserPcmData, data_size, sample_rate);
	[file_url release];
	
	file_url = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"explosion1" ofType:@"wav"]];
	explosion1PcmData = MyGetOpenALAudioDataAll((CFURLRef)file_url, &data_size, &al_format, &sample_rate);
	alBufferDataStatic(explosion1OutputBuffer, al_format, explosion1PcmData, data_size, sample_rate);
	[file_url release];

	file_url = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"explosion2" ofType:@"wav"]];
	explosion2PcmData = MyGetOpenALAudioDataAll((CFURLRef)file_url, &data_size, &al_format, &sample_rate);
	alBufferDataStatic(explosion2OutputBuffer, al_format, explosion2PcmData, data_size, sample_rate);
	[file_url release];

	file_url = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"thrust1" ofType:@"wav"]];
	thrustPcmData = MyGetOpenALAudioDataAll((CFURLRef)file_url, &data_size, &al_format, &sample_rate);
	alBufferDataStatic(thrustOutputBuffer, al_format, thrustPcmData, data_size, sample_rate);
	[file_url release];
	
	alSourcei(self.outputSource1, AL_BUFFER, self.laserOutputBuffer);
	alSourcei(self.outputSource3, AL_BUFFER, self.thrustOutputBuffer);

}

- (void) tearDownOpenAL
{
	alSourceStop(outputSource1);
	alSourceStop(outputSource2);
	alSourceStop(outputSource3);
	alDeleteSources(1, &outputSource1);
	alDeleteSources(1, &outputSource2);
	alDeleteSources(1, &outputSource3);
	alDeleteBuffers(1, &laserOutputBuffer);
	alDeleteBuffers(1, &explosion1OutputBuffer);
	alDeleteBuffers(1, &explosion2OutputBuffer);
	alDeleteBuffers(1, &thrustOutputBuffer);

	alcMakeContextCurrent(NULL);
	if(openALContext)
	{
		alcDestroyContext(openALContext);
		openALContext = NULL;
	}
	if(openALDevice)
	{
		alcCloseDevice(openALDevice);
		openALDevice = NULL;
	}

	if(laserPcmData)
	{
		free(laserPcmData);
		laserPcmData = NULL;
	}
	if(explosion1PcmData)
	{
		free(explosion1PcmData);
		explosion1PcmData = NULL;
	}
	if(explosion2PcmData)
	{
		free(explosion2PcmData);
		explosion2PcmData = NULL;
	}
	if(thrustPcmData)
	{
		free(thrustPcmData);
		thrustPcmData = NULL;
	}
	
}

- (void) dealloc
{
	[self tearDownOpenAL];
	[super dealloc];
}

- (void) playLaser
{
	alSourcePlay(self.outputSource1);
}

- (void) playExplosion1
{
	// Note, loading a buffer on a playing or paused source is technically an error and yields an AL error of AL_INVALID_OPERATION
	ALint source_state = 0;
	alGetSourcei(self.outputSource2, AL_SOURCE_STATE, &source_state);
	if(AL_PLAYING == source_state || AL_PAUSED == source_state)
	{
		alSourceStop(self.outputSource2);
	}
	alSourcei(self.outputSource2, AL_BUFFER, self.explosion1OutputBuffer);
	alSourcePlay(self.outputSource2);
}

- (void) playExplosion2
{
	ALint source_state = 0;
	alGetSourcei(self.outputSource2, AL_SOURCE_STATE, &source_state);
	if(AL_PLAYING == source_state || AL_PAUSED == source_state)
	{
		alSourceStop(self.outputSource2);
	}
	alSourcei(self.outputSource2, AL_BUFFER, self.explosion2OutputBuffer);
	alSourcePlay(self.outputSource2);
}

- (void) playThrust
{
	alSourcei(self.outputSource3, AL_LOOPING, AL_TRUE);
	alSourcePlay(self.outputSource3);
}

- (void) stopThrust
{
	alSourceStop(self.outputSource3);
	alSourcei(self.outputSource3, AL_LOOPING, AL_FALSE);
}


@end
