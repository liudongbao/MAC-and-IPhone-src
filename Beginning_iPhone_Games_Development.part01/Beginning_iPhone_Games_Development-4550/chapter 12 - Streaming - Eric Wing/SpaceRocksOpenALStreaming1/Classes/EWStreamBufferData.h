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
	void* pcmDataBufferArray[EW_STREAM_BUFFER_DATA_MAX_OPENAL_QUEUE_BUFFERS];

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
