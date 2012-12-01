//
//  AVRecorderViewController.h
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVRecorderSoundController;

@interface AVRecorderViewController : UIViewController
{
	IBOutlet AVRecorderSoundController* avRecorderSoundController;
	IBOutlet UIBarButtonItem* playButton;
	IBOutlet UIBarButtonItem* recordButton;
}

@property(nonatomic, retain) AVRecorderSoundController* avRecorderSoundController;

- (IBAction) recordButtonPressed:(id)the_sender;
- (IBAction) playButtonPressed:(id)the_sender;


@end

