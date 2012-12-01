//
//  AudioQueueServicesController.m
//  SpaceRocks
//
//  Created by Eric Wing on 8/19/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "AudioQueueServicesController.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/ExtendedAudioFile.h>


// http://developer.apple.com/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQPlayback/PlayingAudio.html#//apple_ref/doc/uid/TP40005343-CH3-SW2

/* Listing 3-1 */
#define kAudioQueueMaxNumberBuffers 3                 // 1  Listing 3-1

struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;                    // 2  Listing 3-1
    AudioQueueRef                 mQueue;                         // 3  Listing 3-1
    AudioQueueBufferRef           mBuffers[kAudioQueueMaxNumberBuffers];       // 4  Listing 3-1
    AudioFileID                   mAudioFile;                     // 5  Listing 3-1
    UInt32                        bufferByteSize;                 // 6  Listing 3-1
    SInt64                        mCurrentPacket;                 // 7  Listing 3-1
    UInt32                        mNumPacketsToRead;              // 8  Listing 3-1
    AudioStreamPacketDescription  *mPacketDescs;                  // 9  Listing 3-1
    bool                          mIsRunning;                     // 10  Listing 3-1
};


static void HandleOutputBuffer (
								void                 *aqData,                 // 1  Listing 3-2
								AudioQueueRef        inAQ,                    // 2  Listing 3-2
								AudioQueueBufferRef  inBuffer                 // 3  Listing 3-2
) {
	OSStatus result;
    AQPlayerState *pAqData = (AQPlayerState *) aqData;        // 1  Listing 3-6
    if (pAqData->mIsRunning == 0) return;                     // 2  Listing 3-6
    UInt32 numBytesReadFromFile;                              // 3  Listing 3-6
    UInt32 numPackets = pAqData->mNumPacketsToRead;           // 4  Listing 3-6

	result = AudioFileReadPackets (                                          // 1  Listing 3-3
						  pAqData->mAudioFile,                      // 2  Listing 3-3
						  false,                                    // 3  Listing 3-3
						  &numBytesReadFromFile,                    // 4  Listing 3-3
						  pAqData->mPacketDescs,                    // 5  Listing 3-3
						  pAqData->mCurrentPacket,                  // 6  Listing 3-3
						  &numPackets,                              // 7  Listing 3-3
						  inBuffer->mAudioData                      // 8  Listing 3-3
	);
	if(0 != result)
	{
		printf("AudioFileReadPackets failed, %d\n", result);
	}
    if (numPackets > 0) {                                           // 5  Listing 3-6
        inBuffer->mAudioDataByteSize = numBytesReadFromFile;        // 6  Listing 3-6
		
		/* Listing 3-4 */
		result = AudioQueueEnqueueBuffer (                      // 1  Listing 3-4
								 pAqData->mQueue,                           // 2  Listing 3-4
								 inBuffer,                                  // 3  Listing 3-4
								 (pAqData->mPacketDescs ? numPackets : 0),  // 4  Listing 3-4
								 pAqData->mPacketDescs                      // 5  Listing 3-4
		);
		if(0 != result)
		{
			printf("AudioQueueEnqueueBuffer failed, %d\n", result);
		}
        pAqData->mCurrentPacket += numPackets;                // 7  Listing 3-6
    } else {
		// Apple's example ends playback if there is no more data.
		// I modified this so we loop the song.
		/* // Original Code
		 printf("no packets, AudioQueueStop");
		 

			AudioQueueStop (                            // 2  Listing 3-5
							pAqData->mQueue,                        // 3  Listing 3-5
							false                                   // 4  Listing 3-5
							);
			pAqData->mIsRunning = false;                // 5  Listing 3-5
*/		

		// New rewind code
//		printf("rewind");
		

        pAqData->mCurrentPacket = 0; // reset counter
		UInt32 numPackets = pAqData->mNumPacketsToRead; 
		
	    result = AudioFileReadPackets (
									   pAqData->mAudioFile,
									   false,
									   &numBytesReadFromFile,
									   pAqData->mPacketDescs, 
									   0,  // start at the beginning (packet #0)
									   &numPackets,
									   inBuffer->mAudioData 
									   );
		if (numPackets > 0)
		{
			inBuffer->mAudioDataByteSize = numBytesReadFromFile;
			result = AudioQueueEnqueueBuffer ( 
											  pAqData->mQueue,
											  inBuffer,
											  (pAqData->mPacketDescs ? numPackets : 0),
											  pAqData->mPacketDescs
											  );
			if(0 != result)
			{
				printf("AudioQueueEnqueueBuffer failed, %d", result);
			}
			pAqData->mCurrentPacket += numPackets;
		}     
		else 
		{
			
			printf("error with restart, no packets, AudioQueueStop");
			
			AudioQueueStop (                            // 2  Listing 3-5
							pAqData->mQueue,                        // 3  Listing 3-5
							false                                   // 4  Listing 3-5
							);
			if(0 != result)
			{
				printf("AudioQueueStop failed, %d", result);
			}
			pAqData->mIsRunning = false;                // 5  Listing 3-5
		}
		
    }
}


static void DeriveBufferSize (
					   AudioStreamBasicDescription* ASBDesc,                            // 1  Listing 3-7
					   UInt32                      maxPacketSize,                       // 2  Listing 3-7
					   Float64                     seconds,                             // 3  Listing 3-7
					   UInt32                      *outBufferSize,                      // 4  Listing 3-7
					   UInt32                      *outNumPacketsToRead                 // 5  Listing 3-7
) {
    static const int maxBufferSize = 0x50000;                        // 6  Listing 3-7
    static const int minBufferSize = 0x4000;                         // 7  Listing 3-7
	
	
    if (ASBDesc->mFramesPerPacket != 0) {                             // 8  Listing 3-7
        Float64 numPacketsForTime =
		ASBDesc->mSampleRate / ASBDesc->mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {                                                         // 9  Listing 3-7
        *outBufferSize =
		maxBufferSize > maxPacketSize ?
		maxBufferSize : maxPacketSize;
    }
	
    if (                                                             // 10  Listing 3-7
        *outBufferSize > maxBufferSize &&
        *outBufferSize > maxPacketSize
		)
        *outBufferSize = maxBufferSize;
    else {                                                           // 11  Listing 3-7
        if (*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
	
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;           // 12  Listing 3-7
}

// For private methods
@interface AudioQueueServicesController ()
@property(nonatomic, assign) SInt64 savedCurrentPacket;
@property(nonatomic, retain) NSURL* savedFileURL;
- (BOOL) openAudioQueueURL:(NSURL*)file_url startPacket:(SInt64)start_packet;
@end

@implementation AudioQueueServicesController

@synthesize savedCurrentPacket;
@synthesize savedFileURL;

// Note: Listing 3-8 was dropped in favor of the technique we've been using elsewhere.
- (id) initWithSoundFile:(NSString*)sound_file_basename
{
	NSURL* file_url = nil;
	
	// Create a temporary array that contains all the possible file extensions we want to handle.
	// Note: This list is not exhaustive of all the types Core Audio can handle.
	NSArray* file_extension_array = [[NSArray alloc] initWithObjects:@"caf", @"wav", @"aac", @"mp3", @"aiff", @"mp4", @"m4a", nil];
	for(NSString* file_extension in file_extension_array)
	{
		// We need to first check to make sure the file exists otherwise NSURL's initFileWithPath:ofType will crash if the file doesn't exist
		NSString* full_file_name = [NSString stringWithFormat:@"%@/%@.%@", [[NSBundle mainBundle] resourcePath], sound_file_basename, file_extension];
		if(YES == [[NSFileManager defaultManager] fileExistsAtPath:full_file_name])
		{
			file_url = [[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:sound_file_basename ofType:file_extension]] autorelease];
			break;
		}
	}
	[file_extension_array release];
	
	if(nil == file_url)
	{
		NSLog(@"Failed to locate audio file with basename: %@", sound_file_basename);
		return nil;
	}
	audioQueueData = (AQPlayerState*)calloc(1, sizeof(AQPlayerState));
	if(NULL == audioQueueData)
	{
		return nil;
	}
	if(![self openAudioQueueURL:file_url startPacket:0])
	{
		free(audioQueueData);
		audioQueueData = NULL;
		return nil;
	}
	
	self = [super init];
	if(nil != self)
	{
		self.savedFileURL = file_url;
	}
	return self;
	
}

- (BOOL) openAudioQueueURL:(NSURL*)file_url startPacket:(SInt64)start_packet
{
	
	OSStatus result = AudioFileOpenURL (                      // 2  Listing 3-9
										(CFURLRef)file_url,              // 3  Listing 3-9
										0x01/*fsRdPerm*/,     // 4  Listing 3-9, fsRdPerm alias only available on Mac
										0,                    // 5  Listing 3-9
										&audioQueueData->mAudioFile    // 6  Listing 3-9
										);
	
	if(0 != result)
	{
		NSLog(@"AudioFileOpen failed, %d", result);
		return NO;
	}
	
	
	UInt32 dataFormatSize = sizeof (audioQueueData->mDataFormat);    // 1  Listing 3-10
	
	result = AudioFileGetProperty (                                  // 2  Listing 3-10
								   audioQueueData->mAudioFile,                                  // 3  Listing 3-10
								   kAudioFilePropertyDataFormat,                       // 4  Listing 3-10
								   &dataFormatSize,                                    // 5  Listing 3-10
								   &audioQueueData->mDataFormat                                 // 6  Listing 3-10
								   );
	if(0 != result)
	{
		NSLog(@"AudioFileGetProperty failed, %d", result);
	}
	
	
	result = AudioQueueNewOutput (                                // 1  Listing 3-11
								  &audioQueueData->mDataFormat,                             // 2  Listing 3-11
								  HandleOutputBuffer,                              // 3  Listing 3-11
								  audioQueueData,                                         // 4  Listing 3-11
								  CFRunLoopGetCurrent (),                          // 5  Listing 3-11
								  kCFRunLoopCommonModes,                           // 6  Listing 3-11
								  0,                                               // 7  Listing 3-11
								  &audioQueueData->mQueue                                   // 8  Listing 3-11
								  );
	if(0 != result)
	{
		NSLog(@"AudioQueueNewOutput failed, %d", result);
	}
	
	UInt32 maxPacketSize;
	UInt32 propertySize = sizeof (maxPacketSize);
	result = AudioFileGetProperty (                               // 1  Listing 3-12
								   audioQueueData->mAudioFile,                               // 2  Listing 3-12
								   kAudioFilePropertyPacketSizeUpperBound,          // 3  Listing 3-12
								   &propertySize,                                   // 4  Listing 3-12
								   &maxPacketSize                                   // 5  Listing 3-12
								   );
	if(0 != result)
	{
		NSLog(@"AudioFileGetProperty failed, %d", result);
	}
	
	DeriveBufferSize (                                   // 6  Listing 3-12
					  &audioQueueData->mDataFormat,                              // 7  Listing 3-12
					  maxPacketSize,                                   // 8  Listing 3-12
					  0.5,                                             // 9  Listing 3-12
					  &audioQueueData->bufferByteSize,                          // 10  Listing 3-12
					  &audioQueueData->mNumPacketsToRead                        // 11  Listing 3-12
					  );
	//	NSLog(@"bufferByteSize=%d, numPacketsToRead=%d", aqData.bufferByteSize, aqData.mNumPacketsToRead);
	
	bool isFormatVBR = (                                       // 1  Listing 3-13
						audioQueueData->mDataFormat.mBytesPerPacket == 0 ||
						audioQueueData->mDataFormat.mFramesPerPacket == 0
						);
	
	
	
	if (isFormatVBR){                                         // 2  Listing 3-13
		audioQueueData->mPacketDescs =
		(AudioStreamPacketDescription*) malloc (
												audioQueueData->mNumPacketsToRead * sizeof (AudioStreamPacketDescription)
												);
	} else {                                                   // 3  Listing 3-13
		audioQueueData->mPacketDescs = NULL;
	}
	
	UInt32 cookieSize = sizeof (UInt32);                   // 1  Listing 3-14
	bool couldNotGetProperty =                             // 2  Listing 3-14
	AudioFileGetPropertyInfo (                         // 3  Listing 3-14
							  audioQueueData->mAudioFile,                             // 4  Listing 3-14
							  kAudioFilePropertyMagicCookieData,             // 5  Listing 3-14
							  &cookieSize,                                   // 6  Listing 3-14
							  NULL                                           // 7  Listing 3-14
							  );
	
	if (!couldNotGetProperty && cookieSize) {              // 8  Listing 3-14
		char* magicCookie =
		(char *) malloc (cookieSize);
		
		result = AudioFileGetProperty (                             // 9  Listing 3-14
									   audioQueueData->mAudioFile,                             // 10  Listing 3-14
									   kAudioFilePropertyMagicCookieData,             // 11  Listing 3-14
									   &cookieSize,                                   // 12  Listing 3-14
									   magicCookie                                    // 13  Listing 3-14
									   );
		if(0 != result)
		{
			NSLog(@"AudioFileGetProperty failed, %d", result);
		}
		result = AudioQueueSetProperty (                            // 14  Listing 3-14
										audioQueueData->mQueue,                                 // 15  Listing 3-14
										kAudioQueueProperty_MagicCookie,               // 16  Listing 3-14
										magicCookie,                                   // 17  Listing 3-14
										cookieSize                                     // 18  Listing 3-14
										);
		if(0 != result)
		{
			NSLog(@"AudioFileGetProperty failed, %d", result);
		}
		
		free (magicCookie);                                // 19  Listing 3-14
	}
	else
	{
		NSLog(@"Could not get property");
	}
	
	
	// Must be set before HandleOutputBuffer is called or the function escapes
	audioQueueData->mIsRunning = true;                          // 1   Listing 3-17
	audioQueueData->mCurrentPacket = start_packet;                                // 1  Listing 3-15, modified so we can resume
	
	for (int i = 0; i < kAudioQueueMaxNumberBuffers; ++i) {                // 2  Listing 3-15
		result = AudioQueueAllocateBuffer (                            // 3  Listing 3-15
										   audioQueueData->mQueue,                                    // 4  Listing 3-15
										   audioQueueData->bufferByteSize,                            // 5  Listing 3-15
										   &audioQueueData->mBuffers[i]                               // 6  Listing 3-15
										   );
		if(0 != result)
		{
			NSLog(@"AudioQueueAllocateBuffer failed, %d", result);
		}
		
		HandleOutputBuffer (                                  // 7  Listing 3-15
							audioQueueData,                                          // 8  Listing 3-15
							audioQueueData->mQueue,                                    // 9  Listing 3-15
							audioQueueData->mBuffers[i]                                // 10  Listing 3-15
							);
	}
	
	
	[self setGainLevel:1.0];  // 1  Listing 3-16 (encapsulated into a separate method so the user can set it)
	
	// AudioQueueStart for Listing 3-17 has been separated out of this method so we can invoke start separately.
	
	return YES;
}

- (void) setGainLevel:(Float32)gain_level
{
	if(NULL == audioQueueData)
	{
		return;
	}

	gainLevel = gain_level;                                       // 1  Listing 3-16
	OSStatus result = AudioQueueSetParameter (                                  // 2  Listing 3-16
									 audioQueueData->mQueue,                                        // 3  Listing 3-16
									 kAudioQueueParam_Volume,                              // 4  Listing 3-16
									 gainLevel                                                  // 5  Listing 3-16
									 );
	if(0 != result)
	{
		NSLog(@"AudioQueueSetParameter failed, %d", result);
	}
}

- (Float32) gainLevel
{
	return gainLevel;
}

- (void) audioQueueStop
{
	if(NULL == audioQueueData)
	{
		return;
	}
	
	OSStatus result = AudioQueueStop (
									  audioQueueData->mQueue,
									  false
									  );
	if(0 != result)
	{
		printf("AudioQueueStop failed, %d", result);
	}
}

- (void) audioQueueStart
{
	if(NULL == audioQueueData)
	{
		return;
	}
	OSStatus result = AudioQueueStart (                                  // 2   Listing 3-17
							  audioQueueData->mQueue,                                 // 3   Listing 3-17
							  NULL                                           // 4   Listing 3-17
							  );
	if(0 != result)
	{
		NSLog(@"AudioQueueStart failed, %d", result);
	}
}

// See http://developer.apple.com/iphone/library/qa/qa2008/qa1558.html for notes about Audio Queue interruptions
- (void) beginInterruption
{
	if(NULL == audioQueueData)
	{
		return;
	}
	
	[self audioQueueStop];
	self.savedCurrentPacket = audioQueueData->mCurrentPacket;
	[self closeAudioQueue];
}

// See http://developer.apple.com/iphone/library/qa/qa2008/qa1558.html for notes about Audio Queue interruptions
- (void) endInterruption
{
	if(NULL == audioQueueData)
	{
		audioQueueData = (AQPlayerState*)calloc(1, sizeof(AQPlayerState));
		if(NULL == audioQueueData)
		{
			return;
		}
	}
	
	[self openAudioQueueURL:self.savedFileURL startPacket:self.savedCurrentPacket];
	[self audioQueueStart];
}

- (void) closeAudioQueue
{
	if(audioQueueData)
	{
		AudioQueueDispose (                            // 1  Listing 3-18
						   audioQueueData->mQueue,                             // 2  Listing 3-18
						   true                                       // 3  Listing 3-18
						   );
		AudioFileClose (audioQueueData->mAudioFile);            // 4  Listing 3-18
		
		free (audioQueueData->mPacketDescs);                    // 5  Listing 3-18
		
		
		free(audioQueueData);
		audioQueueData = NULL;
	}
}

- (void) dealloc
{
	[self closeAudioQueue];
	[savedFileURL release];
	[super dealloc];
}

@end
