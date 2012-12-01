//
//  EWStreamBufferData.h
//  SpaceRocks
//
//  Created by Eric Wing on 8/4/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <AudioToolbox/ExtendedAudioFile.h>


#define EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS 32

// Ugly Hack: This code was designed with alBufferDataStatic in mind, but due to a bug that I believe to be a
// race condition bug in Apple's OpenAL implementation with this extension when stopping and deleting.
// I'm trying to make it work either way. 
// In the case without the extension, I only want one pcmbuffer to be reused and not multiple buffers to avoid wasting memory.
// The original design assumed a 1 to 1 mapping between albuffer and pcmbuffer, so there is some ugliness.

// Use the alBufferDataStatic extension for streams for extra performance.
// But disable the buffer data static extension in case you get hit by race condition bug.
// #define USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM

@interface EWStreamBufferDataContainer : NSObject
{
	ALuint openalDataBuffer;
	void* pcmDataBuffer;
}

@property(nonatomic, assign) ALuint openalDataBuffer;
@property(nonatomic, assign) void* pcmDataBuffer;

@end

@interface EWStreamBufferData : NSObject
{
	ALenum openalFormat;
	ALsizei dataSize;
	ALsizei sampleRate;
	
	ALuint openalDataBufferArray[EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS];

#ifdef USE_BUFFER_DATA_STATIC_EXTENSION_FOR_STREAM
	void* pcmDataBufferArray[EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS];
#else
	void* pcmDataBuffer;
#endif

	NSMutableArray* availableDataBuffersQueue;
	NSMutableArray* queuedDataBuffersQueue;

	ExtAudioFileRef streamingAudioRef;
	AudioStreamBasicDescription streamingAudioDescription;

	BOOL audioLooping;
	BOOL streamingPaused;
	BOOL atEOF;
}
@property(nonatomic, assign, getter=isAudioLooping) BOOL audioLooping;
@property(nonatomic, assign, getter=isStreamingPaused) BOOL streamingPaused;
@property(nonatomic, assign, getter=isAtEOF) BOOL atEOF;

/**
 * Creates a new EWStreamBufferData object and loads the requested file.
 * @return An EWStreamBufferData object or nil if the file could not be loaded.
 */
+ (EWStreamBufferData*) streamBufferDataFromFileBaseName:(NSString*)sound_file_basename;

- (EWStreamBufferData*) initFromFileBaseName:(NSString*)sound_file_basename;

- (BOOL) updateQueue:(ALuint)streaming_source;

@end
