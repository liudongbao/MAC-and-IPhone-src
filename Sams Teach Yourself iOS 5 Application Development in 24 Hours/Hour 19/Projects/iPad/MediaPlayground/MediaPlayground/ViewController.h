//
//  ViewController.h
//  MediaPlayground
//
//  Created by John Ray on 9/25/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreImage/CoreImage.h>

@interface ViewController : UIViewController <MPMediaPickerControllerDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *toggleFullscreen;
@property (strong, nonatomic) IBOutlet UISwitch *toggleCamera;
@property (strong, nonatomic) IBOutlet UIImageView *displayImageView;
@property (strong, nonatomic) IBOutlet UILabel *displayNowPlaying;
@property (strong, nonatomic) IBOutlet UIButton *musicPlayButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIPopoverController *popoverController;

- (IBAction)playMovie:(id)sender;
- (IBAction)recordAudio:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)chooseImage:(id)sender;
- (IBAction)applyFilter:(id)sender;
- (IBAction)chooseMusic:(id)sender;
- (IBAction)playMusic:(id)sender;

@end
