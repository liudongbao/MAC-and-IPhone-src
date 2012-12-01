//
//  EWSoundBufferData.m
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWSoundBufferData.h"
#include "OpenALSupport.h"


#define USE_BUFFER_DATA_STATIC_EXTENSION


@implementation EWSoundBufferData
@synthesize openalDataBuffer;

- (id) init
{
	ALenum al_error;
	self = [super init];
	if(nil != self)
	{
		alGetError(); // clear errors	
		alGenBuffers(1, &openalDataBuffer);
		al_error = alGetError();
		if(AL_NO_ERROR != al_error)
		{
			NSLog(@"Failed to generate OpenAL data buffer: %s", alGetString(al_error));
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	if(alIsBuffer(openalDataBuffer))
	{
		alDeleteBuffers(1, &openalDataBuffer);
	}
	
	if(NULL != pcmDataBuffer)
	{
		free(pcmDataBuffer);
	}
	
	[super dealloc];
}

/**
 * This method will get the pcm data buffer into an OpenAL buffer. Depending on the #define USE_BUFFER_DATA_STATIC_EXTENSION,
 * it will use alBufferData or alBufferDataStatic to transfer the data.
 * This method assumes ownership of the pcm data buffer.
 * If the extension is in use, the dealloc method will free pcm buffer. If the extension is not used, the pcm data is freed
 * at the end of this method call.
 */
- (void) bindDataBuffer:(void*)pcm_data_buffer withFormat:(ALenum)al_format dataSize:(ALsizei)data_size sampleRate:(ALsizei)sample_rate
{
	pcmDataBuffer = pcm_data_buffer;
	openalFormat = al_format;
	dataSize = data_size;
	sampleRate = sample_rate;
#ifdef USE_BUFFER_DATA_STATIC_EXTENSION
	alBufferDataStatic(openalDataBuffer, al_format, pcm_data_buffer, data_size, sample_rate);
#else
	alBufferData(openalDataBuffer, al_format, pcm_data_buffer, data_size, sample_rate);	
	free(pcmDataBuffer);
	pcmDataBuffer = NULL;
#endif
}

@end
