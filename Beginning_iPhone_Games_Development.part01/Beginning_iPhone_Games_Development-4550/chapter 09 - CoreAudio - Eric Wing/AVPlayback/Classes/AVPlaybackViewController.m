//
//  AVPlaybackViewController.m
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AVPlaybackViewController.h"
#import "AVPlaybackSoundController.h"

@implementation AVPlaybackViewController

@synthesize avPlaybackSoundController;

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[super dealloc];
}


- (IBAction) playButtonPressed:(id)the_sender
{
	[self.avPlaybackSoundController playOrPauseSpeech];
}

- (IBAction) rewindButtonPressed:(id)the_sender
{
	[self.avPlaybackSoundController rewindSpeech];
}

- (IBAction) fastForwardButtonPressed:(id)the_sender
{
	[self.avPlaybackSoundController fastForwardSpeech];	
}


@end
