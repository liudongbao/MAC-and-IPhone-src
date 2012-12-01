//
//  AVPlaybackSoundController.m
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AVPlaybackSoundController.h"

#define SKIP_TIME_AMOUNT 5.0 // 5 seconds
#define MUSIC_VOLUME_REDUCTION 0.4 // 5 seconds

// Nameless category (class continuation) for declaring "private" (helper) methods.
@interface AVPlaybackSoundController ()
- (void) initAudioSession;
- (void) initMusicPlayer;
- (void) initSpeechPlayer;
@end

@implementation AVPlaybackSoundController

@synthesize avMusicPlayer;
@synthesize avSpeechPlayer;



- (void) initAudioSession
{
	// Setup the audio session
	NSError* audio_session_error = nil;
	BOOL is_success = YES;
	
	// 3.0 bug??? AVAudioSessionCategorySoloAmbient always returns error? Just simulator?
//		is_success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&audio_session_error];
	// Set the category
	is_success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&audio_session_error];
	if(!is_success || audio_session_error)
	{
		NSLog(@"Error setting Audio Session category: %@", [audio_session_error localizedDescription]);
	}

	// Make this class the delegate so we can receive the interruption messages
	[[AVAudioSession sharedInstance] setDelegate:self];	

	audio_session_error = nil;
	// Make the Audio Session active
	is_success = [[AVAudioSession sharedInstance] setActive:YES error:&audio_session_error]; 
	if(!is_success || audio_session_error)
	{ 
		NSLog(@"Error setting Audio Session active: %@", [audio_session_error localizedDescription]);
	}
}

- (void) initMusicPlayer
{
	// File is from Internet Archive Open Source Audio, US Army Band, public domain
	// http://www.archive.org/details/TheBattleHymnOfTheRepublic_993
	NSError* file_error = nil;
	NSURL* file_url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"battle_hymn_of_the_republic" ofType:@"mp3"] isDirectory:NO];
	avMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file_url error:&file_error];	
	if(!file_url || file_error)
	{
		NSLog(@"Error loading music file: %@", [file_error localizedDescription]);
	}
	self.avMusicPlayer.delegate = self;
	self.avMusicPlayer.numberOfLoops = -1; // repeat infinitely
	[file_url release];
}

- (void) initSpeechPlayer
{
	// File is from Internet Archive Open Source Audio, Declaration of Independence read by JFK, public domain
	// Trimmed to just the preamble and converted to IMA4 in a .caf container
	// http://www.archive.org/details/TheDeclarationOfIndependence
	// (See the date at the top of this file.)
	NSError* file_error = nil;

	NSURL* file_url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TheDeclarationOfIndependencePreambleJFK" ofType:@"caf"]  isDirectory:NO];
	self.avSpeechPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file_url error:&file_error];	
	if(!file_url || file_error)
	{
		NSLog(@"Error loading speech file: %@", [file_error localizedDescription]);
	}
	self.avSpeechPlayer.delegate = self;

	[file_url release];
}


- (void) awakeFromNib
{
	[super awakeFromNib];
	[self initAudioSession];
	[self initMusicPlayer];
	[self initSpeechPlayer];

	[self.avMusicPlayer play];
}

- (void) dealloc
{
	[avSpeechPlayer release];
	[avMusicPlayer release];
	[[AVAudioSession sharedInstance] setActive:NO error:nil]; // don't care about the error
	
	[super dealloc];
}

#pragma mark User Interface methods
- (void) playOrPauseSpeech
{
	if([self.avSpeechPlayer isPlaying])
	{
		[self.avSpeechPlayer pause];
		self.avMusicPlayer.volume = 1.0;
	}
	else
	{
		[self.avSpeechPlayer play];		
		self.avMusicPlayer.volume = MUSIC_VOLUME_REDUCTION;
	}
}

- (void) rewindSpeech
{
	if(YES == self.avSpeechPlayer.isPlaying)
	{
		[self.avSpeechPlayer stop]; // pause seems to break things with seeking
		self.avSpeechPlayer.currentTime -= SKIP_TIME_AMOUNT;
		[self.avSpeechPlayer play];
	}
	else
	{
		self.avSpeechPlayer.currentTime -= SKIP_TIME_AMOUNT;
	}
}

- (void) fastForwardSpeech
{
	if(YES == self.avSpeechPlayer.isPlaying)
	{
		[self.avSpeechPlayer stop]; // pause seems to break things with seeking
		self.avSpeechPlayer.currentTime += SKIP_TIME_AMOUNT;
		[self.avSpeechPlayer play];
	}
	else
	{
		self.avSpeechPlayer.currentTime += SKIP_TIME_AMOUNT;
	}
}

#pragma mark AVAudioSession delegate methods
- (void) beginInterruption
{
	NSLog(@"AVAudioSession beginInterruption");
}

- (void) endInterruption
{
	NSLog(@"AVAudioSession endInterruption");

	/* Don't reactivate the audio session yourself. 
	 * According to the AVAudioPlayer audioPlayerEndInterruption delegate documentation, it will
	 * automatically restore your session.
	 */
/*
	NSError* audio_session_error = nil;
	BOOL is_success = YES;
	is_success = [[AVAudioSession sharedInstance] setActive:YES error:&audio_session_error]; 
	if(!is_success || audio_session_error)
	{
		NSLog(@"Error setting Audio Session category: %@", [audio_session_error localizedDescription]);
	}
*/
}

#pragma mark AVAudioPlayer delegate methods

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer*)which_player successfully:(BOOL)the_flag
{
	NSLog(@"AVAudioPlayer audioPlayerDidFinishPlaying, successfully:%d", the_flag);
	if(which_player == self.avSpeechPlayer)
	{
		// return volume of music back to max
		self.avMusicPlayer.volume = 1.0;
		// rewind the speech to the beginning for next time
		self.avSpeechPlayer.currentTime = 0.0;
	}

}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)the_player error:(NSError*)the_error
{
	NSLog(@"AVAudioPlayer audioPlayerDecodeErrorDidOccur: %@", [the_error localizedDescription]);
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void) audioPlayerBeginInterruption:(AVAudioPlayer*)which_player
{
	NSLog(@"AVAudioPlayer audioPlayerBeginInterruption");
}

/* audioPlayerEndInterruption: is called when the audio session interruption has ended and this player had been interrupted while playing. 
 The player can be restarted at this point. */
- (void) audioPlayerEndInterruption:(AVAudioPlayer*)which_player
{
	NSLog(@"AVAudioPlayer audioPlayerEndInterruption");

	[which_player play];
}

@end
