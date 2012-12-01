//
//  OpenALSoundController.h
//  SpaceRocks
//
//  Created by Eric Wing on 7/11/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface OpenALSoundController : NSObject
{
	ALCdevice* openALDevice;
	ALCcontext* openALContext;
	ALuint outputSource;
	ALuint laserOutputBuffer;
	void* laserPcmData;
}

@property(nonatomic, assign) ALCdevice* openALDevice;
@property(nonatomic, assign) ALCcontext* openALContext;
@property(nonatomic, assign) ALuint outputSource;
@property(nonatomic, assign) ALuint laserOutputBuffer;

+ (OpenALSoundController*) sharedSoundController;
- (void) initOpenAL;
- (void) tearDownOpenAL;


- (void) playLaser;

@end
