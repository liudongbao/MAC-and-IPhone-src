//
//  BasicOpenALStreamingViewController.h
//  BasicOpenALStreaming
//
//  Created by Eric Wing on 8/1/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenALStreamingController;

@interface BasicOpenALStreamingViewController : UIViewController
{
	IBOutlet OpenALStreamingController* openALStreamingController;
	IBOutlet UIBarButtonItem* playButton;
}

@property(nonatomic, retain) OpenALStreamingController* openALStreamingController;

- (IBAction) playButtonPressed:(id)the_sender;
- (IBAction) volumeSliderMoved:(id)the_sender;

@end

