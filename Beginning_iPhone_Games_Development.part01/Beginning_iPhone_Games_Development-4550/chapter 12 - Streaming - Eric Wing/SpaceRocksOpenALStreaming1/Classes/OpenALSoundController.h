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

@class EWSoundBufferData;
@class EWStreamBufferData;
@protocol EWSoundCallbackDelegate;

@interface OpenALSoundController : NSObject
{
	ALCdevice* openALDevice;
	ALCcontext* openALContext;
	BOOL inInterruption;

	NSMutableDictionary* soundFileDictionary;
	ALuint* allSourcesArray;
	NSMutableSet* availableSourcesCollection;
	NSMutableSet* inUseSourcesCollection;
	NSMutableSet* playingSourcesCollection;
	id<EWSoundCallbackDelegate> soundCallbackDelegate;
	NSMutableArray* interruptionQueue;

	NSMutableDictionary* streamingSourcesDictionary;
}

@property(nonatomic, assign) ALCdevice* openALDevice;
@property(nonatomic, assign) ALCcontext* openALContext;
@property(nonatomic, assign) BOOL inInterruption;
@property(nonatomic, assign) id<EWSoundCallbackDelegate> soundCallbackDelegate;
@property(nonatomic, retain) NSMutableArray* interruptionQueue;
@property(nonatomic, assign) ALenum distanceModel;
@property(nonatomic, assign) ALfloat dopplerFactor;
@property(nonatomic, assign) ALfloat speedOfSound;


+ (OpenALSoundController*) sharedSoundController;
- (void) initOpenAL;
- (void) tearDownOpenAL;

- (EWSoundBufferData*) soundBufferDataFromFileBaseName:(NSString*)sound_file_basename;

- (void) playSound:(ALuint)source_id;
- (void) stopSound:(ALuint)source_id;

- (BOOL) reserveSource:(ALuint*)source_id;
- (void) recycleSource:(ALuint)source_id;

- (void) update;

- (void) queueEvent:(NSInvocation*)an_invocation;

- (EWStreamBufferData*) streamBufferDataFromFileBaseName:(NSString*)sound_file_basename;
- (void) playStream:(ALuint)source_id streamBufferData:(EWStreamBufferData*)stream_buffer_data;
- (void) setSourceGain:(ALfloat)gain_level sourceID:(ALuint)source_id;

@end


@protocol EWSoundCallbackDelegate <NSObject>
@optional

- (void) soundDidFinishPlaying:(NSNumber*)source_number;

@end
