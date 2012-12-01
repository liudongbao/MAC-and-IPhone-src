//
//  AVRecorderSoundController.m
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "AVRecorderSoundController.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

// Nameless category (class continuation) for declaring "private" (helper) methods.
@interface AVRecorderSoundController ()
// Override readonly properties so I can modify them privately in this class.
@property(nonatomic, assign, readwrite, getter=isPlaying) BOOL playing;
@property(nonatomic, assign, readwrite, getter=isRecording) BOOL recording;

@end

@implementation AVRecorderSoundController

@synthesize avPlayer;
@synthesize avRecorder;
@synthesize playing;
@synthesize recording;

- (void) dealloc
{
	[avPlayer release];
	[avRecorder release];
	[[AVAudioSession sharedInstance] setActive:NO error:nil]; // don't care about the error
	
	NSString* temp_dir = NSTemporaryDirectory();
	NSString* recording_file_path = [temp_dir stringByAppendingString: @"audio_recording.caf"];
	[[NSFileManager defaultManager] removeItemAtPath:recording_file_path error:nil];
	[super dealloc];
}

- (void) awakeFromNib
{
	// Since this display's a view on error, this really should be in the view controller and not here,
	// but I place it here so it is easy to find all the important code.
	if(NO == [[AVAudioSession sharedInstance] inputIsAvailable])
	{
		NSLog(@"%@", NSLocalizedString(@"No input device found", @"No input device found"));
		
		UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No input device found", @"No input device found")
			message:NSLocalizedString(@"We could not detect an input device. If you have an external microphone, you should plug it in.", @"Plug in your microphone")
			delegate:nil 
			cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
			otherButtonTitles:nil
		];
		[alert_view show];
		[alert_view release];
	}
}

#pragma mark User Interface methods
- (void) togglePlay
{
	if(YES == self.isRecording)
	{
		// Must stop recording first
		return;
	}

	if(YES == self.isPlaying)
	{
		[self.avPlayer stop];
		self.playing = NO;
		[avPlayer release];
		avPlayer = nil;
		
		// Stop the audio session since we are doing nothing
		[[AVAudioSession sharedInstance] setActive:NO error:nil];
	}
	else
	{
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

		NSString* temp_dir = NSTemporaryDirectory();
		NSString* recording_file_path = [temp_dir stringByAppendingString: @"audio_recording.caf"];
		NSURL* recording_file_url = [[NSURL alloc] initFileURLWithPath:recording_file_path];

		self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recording_file_url error:nil];
		if(nil == self.avPlayer)
		{
			// No file has been recorded yet
			return;
		}
		self.avPlayer.delegate = self;
		
		[recording_file_url release];

		// Start the audio session
		[[AVAudioSession sharedInstance] setActive:YES error:nil];
		
		// Optional: If you don't call this, it will happen at play.
        [self.avPlayer prepareToPlay];
        [self.avPlayer play];
		
		self.playing = YES;
	}
}

- (void) toggleRecord
{
	if(YES == self.isPlaying)
	{
		// Must stop playback first
		return;
	}
	
	if(YES == self.isRecording)
	{
		[self.avRecorder stop];
		self.recording = NO;
		[avRecorder release];
		avRecorder = nil;

		// Stop the audio session since we are doing nothing
		[[AVAudioSession sharedInstance] setActive:NO error:nil];
	}
	else
	{
		// Switch the audio session to record mode
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];

		NSDictionary* record_settings = [[NSDictionary alloc] 
			initWithObjectsAndKeys:
				[NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, // needs CoreAudioTypes.h
				[NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
				nil
		];

		NSString* temp_dir = NSTemporaryDirectory();
		NSString* recording_file_path = [temp_dir stringByAppendingString: @"audio_recording.caf"];
		NSURL* recording_file_url = [[NSURL alloc] initFileURLWithPath:recording_file_path];
		
		
        avRecorder = [[AVAudioRecorder alloc] initWithURL:recording_file_url
			settings:record_settings
			error:nil
		];
		
		
        [record_settings release];
		[recording_file_url release];
        self.avRecorder.delegate = self;

		// Start the audio session
		[[AVAudioSession sharedInstance] setActive:YES error:nil];

		// Optional: Will create file and prepare to record. If you don't call this, it will happen at record.
        [self.avRecorder prepareToRecord];
        [self.avRecorder record];
		
		self.recording = YES;
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

- (void) inputIsAvailableChanged:(BOOL)is_input_available
{
	NSLog(@"AVAudioSession inputIsAvailableChanged:%d", is_input_available);
}


#pragma mark AVAudioPlayer delegate methods

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer*)which_player successfully:(BOOL)the_flag
{
	NSLog(@"AVAudioPlayer audioPlayerDidFinishPlaying, successfully:%d", the_flag);
	self.playing = NO;
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

#pragma mark AVAudioRecorder delegate methods


/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder*)the_recorder successfully:(BOOL)the_flag
{
	NSLog(@"AVAudioRecorder audioRecorderDidFinishRecording, successfully:%d", the_flag);
	// This is a bit redundant since this is also set on toggle-off.
	self.recording = NO;
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder*)the_recorder error:(NSError*)the_error
{
	NSLog(@"AVAudioRecorder audioRecorderEncodeErrorDidOccur: %@", [the_error localizedDescription]);
}

/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorder will have been paused. */
- (void)audioRecorderBeginInterruption:(AVAudioRecorder*)the_recorder
{
	NSLog(@"AVAudioRecorder audioRecorderBeginInterruption");
}

/* audioRecorderEndInterruption: is called when the audio session interruption has ended and this recorder had been interrupted while recording. 
 The recorder can be restarted at this point. */
- (void)audioRecorderEndInterruption:(AVAudioRecorder*)the_recorder
{
	NSLog(@"AVAudioRecorder audioRecorderEndInterruption");
	if(YES == self.isRecording)
	{
		// Continue recording
		[self.avRecorder record];
	}
}

@end
