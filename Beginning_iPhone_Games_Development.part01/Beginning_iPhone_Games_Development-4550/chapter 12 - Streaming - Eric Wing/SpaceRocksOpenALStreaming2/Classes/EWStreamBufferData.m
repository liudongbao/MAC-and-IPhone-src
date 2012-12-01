//
//  EWStreamBufferData.m
//  SpaceRocks
//
//  Created by Eric Wing on 8/4/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWStreamBufferData.h"
#include "OpenALSupport.h"

#define EW_STREAM_BUFFER_DATA_INTERMEDIATE_BUFFER_SIZE 16384

@implementation EWStreamBufferDataContainer
@synthesize openalDataBuffer;
@synthesize pcmDataBuffer;
@end

@interface EWStreamBufferData ()
- (void) createOpenALBuffers;
- (void) destroyOpenALBuffers;
@end


@implementation EWStreamBufferData
@synthesize audioLooping;
@synthesize streamingPaused;
@synthesize atEOF;

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		[self createOpenALBuffers];
	}
	return self;
}

- (EWStreamBufferData*) initFromFileBaseName:(NSString*)sound_file_basename
{
	self = [super init];
	if(nil != self)
	{
		[self createOpenALBuffers];
		
		NSURL* file_url = nil;
		
		// Create a temporary array that contains all the possible file extensions we want to handle.
		// Note: This list is not exhaustive of all the types Core Audio can handle.
		NSArray* file_extension_array = [[NSArray alloc] initWithObjects:@"caf", @"wav", @"aac", @"mp3", @"aiff", @"mp4", @"m4a", nil];
		for(NSString* file_extension in file_extension_array)
		{
			// We need to first check to make sure the file exists otherwise NSURL's initFileWithPath:ofType will crash if the file doesn't exist
			NSString* full_file_name = [NSString stringWithFormat:@"%@/%@.%@", [[NSBundle mainBundle] resourcePath], sound_file_basename, file_extension];
			if(YES == [[NSFileManager defaultManager] fileExistsAtPath:full_file_name])
			{
				file_url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:sound_file_basename ofType:file_extension]];
				break;
			}
		}
		[file_extension_array release];
		
		if(nil == file_url)
		{
			NSLog(@"Failed to locate audio file with basename: %@", sound_file_basename);
			[self release];
			return nil;
		}
		
		streamingAudioRef = MyGetExtAudioFileRef((CFURLRef)file_url, &streamingAudioDescription);
		[file_url release];
		if(NULL == streamingAudioRef)
		{
			NSLog(@"Failed to load audio data from file: %@", sound_file_basename);
			[self release];
			return nil;
		}
	}	
	return self;
}


+ (EWStreamBufferData*) streamBufferDataFromFileBaseName:(NSString*)sound_file_basename
{
	return [[[EWStreamBufferData alloc] initFromFileBaseName:sound_file_basename] autorelease];		
}

- (void) dealloc
{
	[self destroyOpenALBuffers];
	
	if(streamingAudioRef)
	{
		ExtAudioFileDispose(streamingAudioRef);
	}
	
	[super dealloc];
}

- (void) createOpenALBuffers
{
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
	for(NSUInteger i=0; i<EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS; i++)
	{
		pcmDataBufferArray[i] = malloc(EW_STREAM_BUFFER_DATA_INTERMEDIATE_BUFFER_SIZE);
	}
#else
	pcmDataBuffer = malloc(EW_STREAM_BUFFER_DATA_INTERMEDIATE_BUFFER_SIZE);
#endif

	alGenBuffers(EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS, openalDataBufferArray);

	availableDataBuffersQueue = [[NSMutableArray alloc] initWithCapacity:EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS];
	queuedDataBuffersQueue = [[NSMutableArray alloc] initWithCapacity:EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS];
	
	for(NSUInteger i=0; i<EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS; i++)
	{
		EWStreamBufferDataContainer* stream_buffer_data_container = [[EWStreamBufferDataContainer alloc] init];
		stream_buffer_data_container.openalDataBuffer = openalDataBufferArray[i];
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
		stream_buffer_data_container.pcmDataBuffer = pcmDataBufferArray[i];
#else
		stream_buffer_data_container.pcmDataBuffer = NULL;
#endif
		[availableDataBuffersQueue addObject:stream_buffer_data_container];
		[stream_buffer_data_container release];
	}
}

- (void) destroyOpenALBuffers
{
	ALenum al_error = alGetError(); // clear errors just to be sure
	[availableDataBuffersQueue release];
	[queuedDataBuffersQueue release];

	// For USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM, Apple claims I should be checking
	// for an error condition here before trying to delete the PCM buffer.
	// I think there are a lot of problems with that design, and if this does fail,
	// there is no easy way to handle this. The spec actually doesn't specify any other errors
	// than AL_INVALID_NAME so there isn't supposed to be a leaking case.
	// But regardless, they claim I should get an error here right before I delete the in-use PCM buffer
	// and crash, but I'm not getting the error. So there is nothing I can do anyway.
	// To minimize the chance of encountering the race condition, you can add calls 
	// to sleep() or usleep() or do other things to waste time such as call NSLog().
	alDeleteBuffers(EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS, openalDataBufferArray);
	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"EWStreamBufferData alDeleteBuffers error: %s", alGetString(al_error));
	}
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
	for(NSUInteger i=0; i<EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS; i++)
	{
		if(NULL != pcmDataBufferArray[i])
		{
			free(pcmDataBufferArray[i]);
			pcmDataBufferArray[i] = NULL;			
		}
	}
#else
	if(NULL != pcmDataBuffer)
	{
		free(pcmDataBuffer);
		pcmDataBuffer = NULL;			
	}
#endif
}

- (BOOL) updateQueue:(ALuint)streaming_source
{
	
	ALenum al_error;	
	ALint buffers_processed = 0;
	BOOL finished_playing = NO;
	
	alGetSourcei(streaming_source, AL_BUFFERS_PROCESSED, &buffers_processed);
	al_error = alGetError();
	if(AL_NO_ERROR != al_error)
	{
		NSLog(@"alGetSourcei error1: %s", alGetString(al_error));
	}

	while(buffers_processed > 0)
	{
		ALuint unqueued_buffer;
		alSourceUnqueueBuffers(streaming_source, 1, &unqueued_buffer);
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alSourceUnqueueBuffers error: %s", alGetString(al_error));
		}

		[availableDataBuffersQueue insertObject:[queuedDataBuffersQueue lastObject] atIndex:0];
		[queuedDataBuffersQueue removeLastObject];
		
		buffers_processed--;
	}
	
	if([availableDataBuffersQueue count] > 0 && NO == self.isAtEOF)
	{
		// Have more buffers to queue
		EWStreamBufferDataContainer* current_stream_buffer_data_container = [availableDataBuffersQueue lastObject];		
		ALuint current_buffer = current_stream_buffer_data_container.openalDataBuffer;
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
		void* current_pcm_buffer = current_stream_buffer_data_container.pcmDataBuffer;
#else
		void* current_pcm_buffer = pcmDataBuffer;
#endif
		ALenum al_format;
		ALsizei buffer_size;
		ALsizei sample_rate;

		MyGetDataFromExtAudioRef(streamingAudioRef, &streamingAudioDescription, EW_STREAM_BUFFER_DATA_INTERMEDIATE_BUFFER_SIZE, &current_pcm_buffer, &buffer_size, &al_format, &sample_rate);
		if(0 == buffer_size) // will loop music on EOF (which is 0 bytes)
		{
			if(YES == self.isAudioLooping)
			{
				MyRewindExtAudioData(streamingAudioRef);
				MyGetDataFromExtAudioRef(streamingAudioRef, &streamingAudioDescription, EW_STREAM_BUFFER_DATA_INTERMEDIATE_BUFFER_SIZE, &current_pcm_buffer, &buffer_size, &al_format, &sample_rate);				
			}
			else
			{
				self.atEOF = YES;
			}
		}

		if(buffer_size > 0)
		{
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
			alBufferDataStatic(current_buffer, al_format, current_pcm_buffer, buffer_size, sample_rate);
#else
			alBufferData(current_buffer, al_format, current_pcm_buffer, buffer_size, sample_rate);
#endif
			al_error = alGetError();
			if(AL_NO_ERROR != al_error)
			{
				NSLog(@"alBufferDataStatic error: %s", alGetString(al_error));
			}
			alSourceQueueBuffers(streaming_source, 1, &current_buffer);
			al_error = alGetError();
			if(AL_NO_ERROR != al_error)
			{
				NSLog(@"alSourceQueueBuffers error: %s", alGetString(al_error));
			}

			[queuedDataBuffersQueue insertObject:current_stream_buffer_data_container atIndex:0];
			[availableDataBuffersQueue removeLastObject];


			ALenum current_playing_state;
			alGetSourcei(streaming_source, AL_SOURCE_STATE, &current_playing_state);
			al_error = alGetError();
			if(AL_NO_ERROR != al_error)
			{
				NSLog(@"alGetSourcei error2: %s", alGetString(al_error));
			}
			// Handle buffer underrun case
			if(AL_PLAYING != current_playing_state)
			{
				ALint buffers_queued = 0;
				
				alGetSourcei(streaming_source, AL_BUFFERS_QUEUED, &buffers_queued);
				if(AL_NO_ERROR != al_error)
				{
					NSLog(@"alGetSourcei AL_BUFFERS_QUEUED error: %s", alGetString(al_error));
				}
				//			NSLog(@"Playing is not AL_PLAYING: %x, buffers_queued:%d", current_playing_state, buffers_queued);
				
				
				if(buffers_queued > 0 && NO == self.isStreamingPaused)
				{
					// need to restart play
//					NSLog(@"Underrun");
					alSourcePlay(streaming_source);
					al_error = alGetError();
					if(AL_NO_ERROR != al_error)
					{
						NSLog(@"alSourcePlay error: %s", alGetString(al_error));
					}
				}
				
			}
		}
	}
	
	if(YES == self.isAtEOF)
	{
		ALenum current_playing_state;
		
		alGetSourcei(streaming_source, AL_SOURCE_STATE, &current_playing_state);
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"alGetSourcei AL_SOURCE_STATE error3: %s", alGetString(al_error));
		}
		
		if(AL_STOPPED == current_playing_state)
		{
			finished_playing = YES;
			
			// Theoretically, there is a race condition where the last buffer(s) were processed
			// after we passed the unqueue part of our function.
			// So to be paranoid, we can run the code again to make sure everything is clear.
			alGetSourcei(streaming_source, AL_BUFFERS_PROCESSED, &buffers_processed);
			al_error = alGetError();
			if(AL_NO_ERROR != al_error)
			{
				NSLog(@"alGetSourcei error1: %s", alGetString(al_error));
			}
			
			while(buffers_processed > 0)
			{
				ALuint unqueued_buffer;
				alSourceUnqueueBuffers(streaming_source, 1, &unqueued_buffer);
				al_error = alGetError();
				if(AL_NO_ERROR != al_error)
				{
					NSLog(@"alSourceUnqueueBuffers error: %s", alGetString(al_error));
				}
				
				[availableDataBuffersQueue insertObject:[queuedDataBuffersQueue lastObject] atIndex:0];
				[queuedDataBuffersQueue removeLastObject];
				
				buffers_processed--;
			}
		}
	}

	return finished_playing;
}

@end
