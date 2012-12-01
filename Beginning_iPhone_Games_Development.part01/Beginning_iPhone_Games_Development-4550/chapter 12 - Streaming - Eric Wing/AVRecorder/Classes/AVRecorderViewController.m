//
//  AVRecorderViewController.m
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import "AVRecorderViewController.h"
#import "AVRecorderSoundController.h"

@implementation AVRecorderViewController

@synthesize avRecorderSoundController;

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidLoad
{
	// Use Key-Value-Observing (KVO) to listen for changes to the "model's" properties
	// so we know when to disable and enable our buttons.
	[self addObserver:self forKeyPath:@"avRecorderSoundController.recording" 
		options:NSKeyValueObservingOptionNew context:NULL];

	[self addObserver:self forKeyPath:@"avRecorderSoundController.playing" 
			  options:NSKeyValueObservingOptionNew context:NULL];
}


- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}

- (void)observeValueForKeyPath:(NSString*)key_path 
	ofObject:(id)the_object 
	change:(NSDictionary*)the_change
	context:(void*)the_context
{
	if([key_path isEqualToString:@"avRecorderSoundController.recording"])
	{
//		NSLog(@"avRecorderSoundController.recording changed");
		if(YES == avRecorderSoundController.isRecording)
		{
			playButton.enabled = NO;
		}
		else
		{
			playButton.enabled = YES;
		}
	}
	else if([key_path isEqualToString:@"avRecorderSoundController.playing"])
	{
//		NSLog(@"avRecorderSoundController.playing changed");
		if(YES == avRecorderSoundController.isPlaying)
		{
			recordButton.enabled = NO;
		}
		else
		{
			recordButton.enabled = YES;
		}
	}
}

- (void) dealloc
{
	[self removeObserver:self forKeyPath:@"avRecorderSoundController.playing"];
	[self removeObserver:self forKeyPath:@"avRecorderSoundController.recording"];

	[super dealloc];
}


- (IBAction) playButtonPressed:(id)the_sender
{
	[self.avRecorderSoundController togglePlay];
}

- (IBAction) recordButtonPressed:(id)the_sender
{
	[self.avRecorderSoundController toggleRecord];
}

@end
