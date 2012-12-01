//
//  EWSoundBufferData.h
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@interface EWSoundBufferData : NSObject
{
	ALuint openalDataBuffer;
	void* pcmDataBuffer;
	ALenum openalFormat;
	ALsizei dataSize;
	ALsizei sampleRate;
}

@property(nonatomic, assign, readonly) ALuint openalDataBuffer;

- (void) bindDataBuffer:(void*)pcm_data_buffer withFormat:(ALenum)al_format dataSize:(ALsizei)data_size sampleRate:(ALsizei)sample_rate;

@end

