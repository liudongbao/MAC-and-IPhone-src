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
	ALuint outputSource1;
	ALuint outputSource2;
	ALuint outputSource3;

	ALuint laserOutputBuffer;
	ALuint explosion1OutputBuffer;
	ALuint explosion2OutputBuffer;
	ALuint thrustOutputBuffer;
	void* laserPcmData;
	void* explosion1PcmData;
	void* explosion2PcmData;
	void* thrustPcmData;
}

@property(nonatomic, assign) ALCdevice* openALDevice;
@property(nonatomic, assign) ALCcontext* openALContext;
@property(nonatomic, assign) ALuint outputSource1;
@property(nonatomic, assign) ALuint outputSource2;
@property(nonatomic, assign) ALuint outputSource3;
@property(nonatomic, assign) ALuint laserOutputBuffer;
@property(nonatomic, assign) ALuint explosion1OutputBuffer;
@property(nonatomic, assign) ALuint explosion2OutputBuffer;
@property(nonatomic, assign) ALuint thrustOutputBuffer;

+ (OpenALSoundController*) sharedSoundController;
- (void) initOpenAL;
- (void) tearDownOpenAL;


- (void) playLaser;
- (void) playExplosion1;
- (void) playExplosion2;
- (void) playThrust;
- (void) stopThrust;

@end
