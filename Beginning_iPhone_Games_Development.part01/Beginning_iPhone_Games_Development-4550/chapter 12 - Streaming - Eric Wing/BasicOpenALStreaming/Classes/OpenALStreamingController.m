//
//  OpenALStreamingController.m
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "OpenALStreamingController.h"
#include "AudioSessionSupport.h"
#include "OpenALSupport.h"

#define INTERMEDIATE_BUFFER_SIZE 32768

static void MyInterruptionCallback(void* user_data, UInt32 interruption_state)
{
	OpenALStreamingController* openal_streaming_controller = (OpenALStreamingController*)user_data;
	if(kAudioSessionBeginInterruption == interruption_state)
	{
		openal_streaming_controller.inInterruption = YES;
		alcSuspendContext(openal_streaming_controller.openALContext);
		alcMakeContextCurrent(NULL);
	}
	else if(kAudioSessionEndInterruption == interruption_state)
	{
		OSStatus the_error = AudioSessionSetActive(true);
		if(noErr != the_error)
		{
			printf("Error setting audio session active! %s\n", FourCCToString(the_error));
		}
		alcMakeContextCurrent(openal_streaming_controller.openALContext);
		alcProcessContext(openal_streaming_controller.openALContext);
		openal_streaming_controller.inInterruption = NO;
	}
}


@implementation OpenALStreamingController

@synthesize openALDevice;
@synthesize openALContext;
@synthesize inInterruption;
@synthesize streamingPaused;

- (void) awakeFromNib
{
	[super awakeFromNib];
	InitAudioSession(kAudioSessionCategory_SoloAmbientSound, MyInterruptionCallback, self, 44100.0);
	[self initOpenAL];
	streamingPaused = YES;
	[self initAnimationTimer];
}

- (void) dealloc
{
	[self tearDownOpenAL];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
	[displayLink invalidate];
	[displayLink release];
#else
	[animationTimer invalidate];
	[animationTimer release];
#endif
	[super dealloc];
}

- (void) initOpenAL
{
	openALDevice = alcOpenDevice(NULL);
	if(openALDevice != NULL)
	{
		// Use the Apple extension to set the mixer rate
		alcMacOSXMixerOutputRate(44100.0);
		
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
		
	alGenSources(1, &streamingSource);
	alGenBuffers(MAX_OPENAL_QUEUE_BUFFERS, availableALBufferArray);
	availableALBufferArrayCurrentIndex = 0;

	// File is from Internet Archive Open Source Audio, US Army Band, public domain
	// http://www.archive.org/details/TheBattleHymnOfTheRepublic_993
	NSURL* file_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"battle_hymn_of_the_republic" ofType:@"mp3"]];
	if(file_url)
	{	
		streamingAudioRef = MyGetExtAudioFileRef((CFURLRef)file_url, &streamingAudioDescription);
	}
	else
	{
		NSLog(@"Could not find file!\n");
		streamingAudioRef = NULL;
	}

	intermediateDataBuffer = malloc(INTERMEDIATE_BUFFER_SIZE);
}

- (void) tearDownOpenAL
{
	alSourceStop(streamingSource);
	alDeleteSources(1, &streamingSource);
	alDeleteBuffers(MAX_OPENAL_QUEUE_BUFFERS, &streamingSource);
	
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
	if(intermediateDataBuffer)
	{
		free(intermediateDataBuffer);		
	}
	if(streamingAudioRef)
	{
		ExtAudioFileDispose(streamingAudioRef);
	}
}


- (void) initAnimationTimer
{
NSLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED = %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
#warning "In displayLink"
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationCallback:)];
	[displayLink retain];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	NSLog(@"using displayLink");
#else
#warning "In timer"
	animationTimer = [NSTimer
					  scheduledTimerWithTimeInterval:1.0/(60.0) // fps
					  target:self
					  selector:@selector(animationCallback:)
					  userInfo:nil
					  repeats:YES];
	
	[animationTimer retain];
	NSLog(@"using timer");

#endif	
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
- (void) animationCallback:(CADisplayLink*)display_link
#else
- (void) animationCallback:(NSTimer*)the_timer
#endif
{
	if(YES == inInterruption)
	{
		return;
	}
	
	ALenum al_error;	
	ALint buffers_processed = 0;

	alGetSourcei(streamingSource, AL_BUFFERS_PROCESSED, &buffers_processed);
	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"alGetSourcei error: %s", alGetString(al_error));
	}
	
	while(buffers_processed > 0)
	{
		//				NSLog(@"animationCallback: unqueuing buffer, availableALBufferArrayCurrentIndex=%d", availableALBufferArrayCurrentIndex);
		
		ALuint unqueued_buffer;
		alSourceUnqueueBuffers(streamingSource, 1, &unqueued_buffer);
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alSourceUnqueueBuffers error: %s", alGetString(al_error));
		}
		
		availableALBufferArrayCurrentIndex--;
		availableALBufferArray[availableALBufferArrayCurrentIndex] = unqueued_buffer;
		
		buffers_processed--;
	}
	
	if(availableALBufferArrayCurrentIndex < MAX_OPENAL_QUEUE_BUFFERS)
	{
		//				NSLog(@"animationCallback: queuing buffer, availableALBufferArrayCurrentIndex=%d", availableALBufferArrayCurrentIndex);
		
		// Have more buffers to queue
		ALuint current_buffer = availableALBufferArray[availableALBufferArrayCurrentIndex];
		
		ALsizei buffer_size;
		ALenum data_format;
		ALsizei sample_rate;
		
		MyGetDataFromExtAudioRef(streamingAudioRef, &streamingAudioDescription, INTERMEDIATE_BUFFER_SIZE, &intermediateDataBuffer, &buffer_size, &data_format, &sample_rate);
		if(0 == buffer_size) // will loop music on EOF (which is 0 bytes)
		{
			MyRewindExtAudioData(streamingAudioRef);
			MyGetDataFromExtAudioRef(streamingAudioRef, &streamingAudioDescription, INTERMEDIATE_BUFFER_SIZE, &intermediateDataBuffer, &buffer_size, &data_format, &sample_rate);
		}
		alBufferData(current_buffer, data_format, intermediateDataBuffer, buffer_size, sample_rate);
		alSourceQueueBuffers(streamingSource, 1, &current_buffer);
		availableALBufferArrayCurrentIndex++;

		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alSourceQueueBuffers error: %s", alGetString(al_error));
		}
		ALenum current_playing_state;
		
		alGetSourcei(streamingSource, AL_SOURCE_STATE, &current_playing_state);
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alGetSourcei error: %s", alGetString(al_error));
		}
		// Handle buffer underrun case
		if(AL_PLAYING != current_playing_state)
		{
			ALint buffers_queued = 0;

			alGetSourcei(streamingSource, AL_BUFFERS_QUEUED, &buffers_queued);
//			NSLog(@"Playing is not AL_PLAYING: %x, buffers_queued:%d", current_playing_state, buffers_queued);

			if(buffers_queued > 0 && NO == self.isStreamingPaused)
			{
				// need to restart play
				alSourcePlay(streamingSource);
				al_error = alGetError();
				if(AL_NO_ERROR != al_error)
				{
					NSLog(@"alSourcePlay error: %s", alGetString(al_error));
				}
			}
			
		}
	}
}

#pragma mark User Interface methods
- (void) playOrPause
{
	if(YES == self.isStreamingPaused)
	{
		self.streamingPaused = NO;
		alSourcePlay(streamingSource);
	}
	else
	{
		self.streamingPaused = YES;
		alSourcePause(streamingSource);
	}
}

- (void) setVolume:(ALfloat)new_volume
{
	alListenerf(AL_GAIN, new_volume);
}

@end
