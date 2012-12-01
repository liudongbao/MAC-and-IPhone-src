//
//  IPodMusicController.m
//  SpaceRocks
//
//  Created by Eric Wing on 8/17/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "IPodMusicController.h"


@implementation IPodMusicController

// Singleton accessor.  this is how you should ALWAYS get a reference
// to the scene controller.  Never init your own. 
+ (IPodMusicController*) sharedMusicController
{
	static IPodMusicController* shared_music_controller;
	@synchronized(self)
	{
		if(nil == shared_music_controller)
		{
			shared_music_controller = [[IPodMusicController alloc] init];
		}
		return shared_music_controller;
	}
	return shared_music_controller;
}


- (void) startApplication
{
//	MPMusicPlayerController* music_player = [MPMusicPlayerController applicationMusicPlayer];
	MPMusicPlayerController* music_player = [MPMusicPlayerController iPodMusicPlayer];
	// Set or otherwise take iPod's current modes
	// [music_player setShuffleMode:MPMusicShuffleModeOff];
	// [music_player setRepeatMode:MPMusicRepeatModeNone];
	
	if(MPMusicPlaybackStateStopped == music_player.playbackState)
	{
		// Get all songs in the library and make them the list to play
		[music_player setQueueWithQuery:[MPMediaQuery songsQuery]];
		[music_player play];		
	}
	else if(MPMusicPlaybackStatePaused == music_player.playbackState)
	{
		// Assuming that a song is already been selected to play
		[music_player play];		
	}
	else if(MPMusicPlaybackStatePlaying == music_player.playbackState)
	{
		// do nothing, let it continue playing
	}
	else
	{
		NSLog(@"Unhandled MPMusicPlayerController state: %d", music_player.playbackState);
	}	
}

- (void) presentMediaPicker:(UIViewController*)current_view_controller
{
	MPMediaPickerController* media_picker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio] autorelease];
	[media_picker setDelegate:self];
	[media_picker setAllowsPickingMultipleItems:YES];
	// For a message at the top of the view
	media_picker.prompt = NSLocalizedString(@"Add songs to play", "Prompt in media item picker");
	
	[current_view_controller presentModalViewController:media_picker animated:YES];
}

#pragma mark MPMediaPickerControllerDelegate methods

- (void) mediaPicker:(MPMediaPickerController*)media_picker didPickMediaItems:(MPMediaItemCollection*)item_collection
{
	MPMusicPlayerController* music_player = [MPMusicPlayerController iPodMusicPlayer];
	[music_player setQueueWithItemCollection:item_collection];
	[music_player play];	

    [media_picker.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)media_picker
{
    [media_picker.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
