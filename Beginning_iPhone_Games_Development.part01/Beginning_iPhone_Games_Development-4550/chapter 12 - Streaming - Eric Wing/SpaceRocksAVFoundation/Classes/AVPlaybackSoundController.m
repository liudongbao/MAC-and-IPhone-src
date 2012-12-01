//
//  AVPlaybackSoundController.m
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AVPlaybackSoundController.h"

@implementation AVPlaybackSoundController

@synthesize avStreamPlayer;


- (id) initWithSoundFile:(NSString*)sound_file_basename
{
	NSURL* file_url = nil;
	NSError* file_error = nil;

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
	
	self = [super init];
	if(nil != self)
	{
		avStreamPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file_url error:&file_error];	
		if(file_error)
		{
			NSLog(@"Error loading stream file: %@", [file_error localizedDescription]);
		}
		avStreamPlayer.delegate = self;
		// Optional: Presumably, the player will start buffering now instead of on play.
		[avStreamPlayer prepareToPlay];
	}
	return self;
}

- (void) play
{
	[self.avStreamPlayer play];
}

- (void) pause
{
	[self.avStreamPlayer pause];
}

- (void) stop
{
	[self.avStreamPlayer stop];
}

- (void) setNumberOfLoops:(NSInteger)number_of_loops
{
	self.avStreamPlayer.numberOfLoops = number_of_loops;
}

- (NSInteger) numberOfLoops
{
	return self.avStreamPlayer.numberOfLoops;
}

- (void) setVolume:(float)volume_level
{
	self.avStreamPlayer.volume = volume_level;
}

- (float) volume
{
	return self.avStreamPlayer.volume;
}

- (void) dealloc
{
	[avStreamPlayer release];
	[super dealloc];
}

#pragma mark AVAudioPlayer delegate methods

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer*)which_player successfully:(BOOL)the_flag
{
//	NSLog(@"AVAudioPlayer audioPlayerDidFinishPlaying, successfully:%d", the_flag);
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)the_player error:(NSError*)the_error
{
	NSLog(@"AVAudioPlayer audioPlayerDecodeErrorDidOccur: %@", [the_error localizedDescription]);
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void) audioPlayerBeginInterruption:(AVAudioPlayer*)which_player
{
//	NSLog(@"AVAudioPlayer audioPlayerBeginInterruption");
}

/* audioPlayerEndInterruption: is called when the audio session interruption has ended and this player had been interrupted while playing. 
 The player can be restarted at this point. */
- (void) audioPlayerEndInterruption:(AVAudioPlayer*)which_player
{
//	NSLog(@"AVAudioPlayer audioPlayerEndInterruption");

	[which_player play];
}

@end
