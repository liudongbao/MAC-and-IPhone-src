//
//  BasicOpenALStreamingViewController.m
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import "BasicOpenALStreamingViewController.h"
#import "OpenALStreamingController.h"

@implementation BasicOpenALStreamingViewController


@synthesize openALStreamingController;

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
	[self.openALStreamingController playOrPause];
}

- (IBAction) volumeSliderMoved:(id)the_sender
{
	UISlider* the_slider = (UISlider*)the_sender;
	[self.openALStreamingController setVolume:the_slider.value];
}


@end
