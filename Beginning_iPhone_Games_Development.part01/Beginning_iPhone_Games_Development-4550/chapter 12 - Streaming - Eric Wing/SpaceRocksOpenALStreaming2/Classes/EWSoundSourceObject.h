//
//  EWSoundSourceObject.h
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import "EWSoundState.h"
#import "OpenALSoundController.h"
#import "BBPoint.h"

@class EWSoundBufferData;

@interface EWSoundSourceObject : EWSoundState
{
	ALuint sourceID;
	BOOL hasSourceID;
	ALboolean audioLooping;
	ALfloat pitchShift;
	ALfloat rolloffFactor;
	ALfloat referenceDistance;
	ALfloat maxDistance;
	BBPoint atDirection;
	ALfloat coneInnerAngle;
	ALfloat coneOuterAngle;
	ALfloat coneOuterGain;
	ALboolean sourceRelative;
	BOOL positionalDisabled;
}

@property(nonatomic, assign) ALuint sourceID;
@property(nonatomic, assign) BOOL hasSourceID;
@property(nonatomic, assign, getter=isAudioLooping) ALboolean audioLooping;
@property(nonatomic, assign) ALfloat pitchShift;
@property(nonatomic, assign) ALfloat rolloffFactor;
@property(nonatomic, assign) ALfloat referenceDistance;
@property(nonatomic, assign) ALfloat maxDistance;
@property(nonatomic, assign) BBPoint atDirection;
@property(nonatomic, assign) ALfloat coneInnerAngle;
@property(nonatomic, assign) ALfloat coneOuterAngle;
@property(nonatomic, assign) ALfloat coneOuterGain;
@property(nonatomic, assign, getter=isSourceRelative) ALboolean sourceRelative;
@property(nonatomic, assign, getter=isPositionalDisabled) BOOL positionalDisabled;

- (void) applyState;
- (void) update;

- (BOOL) playSound:(EWSoundBufferData*)sound_buffer_data;
- (void) stopSound;

- (BOOL) playStream:(EWStreamBufferData*)stream_buffer_data;

- (void) soundDidFinishPlaying:(NSNumber*)source_number;

@end

