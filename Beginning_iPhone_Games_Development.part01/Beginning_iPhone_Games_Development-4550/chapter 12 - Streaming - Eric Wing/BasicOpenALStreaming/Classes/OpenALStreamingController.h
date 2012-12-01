//
//  OpenALStreamingController.h
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <Availability.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
	#import <QuartzCore/QuartzCore.h> // for CADisplayLink
#endif

#define MAX_OPENAL_QUEUE_BUFFERS 5

@interface OpenALStreamingController : NSObject
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
	CADisplayLink* displayLink;
#else
	NSTimer* animationTimer;
#endif

	ALCdevice* openALDevice;
	ALCcontext* openALContext;
	BOOL inInterruption;

	ALuint streamingSource;

	ALuint availableALBufferArray[MAX_OPENAL_QUEUE_BUFFERS];
	ALuint availableALBufferArrayCurrentIndex;

	ExtAudioFileRef streamingAudioRef;
	AudioStreamBasicDescription streamingAudioDescription;
	void* intermediateDataBuffer;
	BOOL streamingPaused;

}

@property(nonatomic, assign) ALCdevice* openALDevice;
@property(nonatomic, assign) ALCcontext* openALContext;
@property(nonatomic, assign) BOOL inInterruption;
@property(nonatomic, assign, getter=isStreamingPaused) BOOL streamingPaused;

- (void) initOpenAL;
- (void) tearDownOpenAL;
- (void) initAnimationTimer;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
- (void) animationCallback:(CADisplayLink*)display_link;
#else
- (void) animationCallback:(NSTimer*)the_timer;
#endif

- (void) playOrPause;
- (void) setVolume:(ALfloat)new_volume;

@end
