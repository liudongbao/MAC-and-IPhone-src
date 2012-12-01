//
//  AudioQueueServicesController.h
//  SpaceRocks
//
//  Created by Eric Wing on 8/19/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct AQPlayerState AQPlayerState;

@interface AudioQueueServicesController : NSObject
{
	AQPlayerState* audioQueueData; //  1  Listing 3-9, Note: I changed the variable name from aqData
	Float32 gainLevel;
	SInt64 savedCurrentPacket; // for interruption
	NSURL* savedFileURL; // for interruption
}

@property(nonatomic, assign) Float32 gainLevel;

// designated initializer
- (id) initWithSoundFile:(NSString*)sound_file_basename;

- (void) audioQueueStop;
- (void) audioQueueStart;

// Intended for interruptions
- (void) beginInterruption;
- (void) endInterruption;


// Intended for shutdown
- (void) closeAudioQueue;

@end
