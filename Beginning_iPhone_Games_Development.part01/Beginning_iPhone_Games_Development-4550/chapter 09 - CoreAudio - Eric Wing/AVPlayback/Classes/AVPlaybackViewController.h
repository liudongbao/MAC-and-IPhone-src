//
//  AVPlaybackViewController.h
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlaybackSoundController;

@interface AVPlaybackViewController : UIViewController
{
	IBOutlet AVPlaybackSoundController* avPlaybackSoundController;
	IBOutlet UIBarButtonItem* playButton;
}

@property(nonatomic, retain) AVPlaybackSoundController* avPlaybackSoundController;

- (IBAction) playButtonPressed:(id)the_sender;
- (IBAction) rewindButtonPressed:(id)the_sender;
- (IBAction) fastForwardButtonPressed:(id)the_sender;


@end

