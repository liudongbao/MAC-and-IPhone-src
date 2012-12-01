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
@synthesize outputSource;
@synthesize laserOutputBuffer;


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
	
	alGenSources(1, &outputSource);
	alGenBuffers(1, &laserOutputBuffer);
	
	ALsizei data_size;
	ALenum al_format;
	ALsizei sample_rate;
	NSURL* file_url;

	file_url = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"laser1" ofType:@"wav"]];
	laserPcmData = MyGetOpenALAudioDataAll((CFURLRef)file_url, &data_size, &al_format, &sample_rate);
	alBufferDataStatic(laserOutputBuffer, al_format, laserPcmData, data_size, sample_rate);
	[file_url release];	

	alSourcei(self.outputSource, AL_BUFFER, self.laserOutputBuffer);
}

- (void) tearDownOpenAL
{
	alDeleteSources(1, &outputSource);
	alDeleteBuffers(1, &laserOutputBuffer);

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
	
}

- (void) dealloc
{
	[self tearDownOpenAL];
	[super dealloc];
}

- (void) playLaser
{
	alSourcePlay(self.outputSource);
}

@end
