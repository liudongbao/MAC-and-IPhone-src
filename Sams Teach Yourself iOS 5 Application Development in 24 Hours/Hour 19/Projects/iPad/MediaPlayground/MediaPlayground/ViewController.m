//
//  ViewController.m
//  MediaPlayground
//
//  Created by John Ray on 9/25/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize toggleFullscreen;
@synthesize toggleCamera;
@synthesize displayImageView;
@synthesize displayNowPlaying;
@synthesize musicPlayButton;
@synthesize audioRecorder;
@synthesize audioPlayer;
@synthesize musicPlayer;
@synthesize moviePlayer;
@synthesize recordButton;
@synthesize popoverController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //Setup the movie player
    NSString *movieFile = [[NSBundle mainBundle] 
                           pathForResource:@"movie" ofType:@"m4v"];
	self.moviePlayer = [[MPMoviePlayerController alloc] 
                        initWithContentURL: [NSURL 
                                             fileURLWithPath: 
                                             movieFile]];
    self.moviePlayer.allowsAirPlay=YES;
    [self.moviePlayer.view setFrame:
                        CGRectMake(415.0, 50.0, 300.0, 250.0)];
    

    //Setup the audio recorder
    NSURL *soundFileURL=[NSURL fileURLWithPath: 
                         [NSTemporaryDirectory() 
                          stringByAppendingString:@"sound.caf"]];
	
	NSDictionary *soundSetting;
    soundSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
                [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,
                [NSNumber numberWithInt: AVAudioQualityHigh],
                    AVEncoderAudioQualityKey,nil];
	
	self.audioRecorder = [[AVAudioRecorder alloc] 
                          initWithURL: soundFileURL
                          settings: soundSetting
                          error: nil];
    
    //Setup the audio player
    NSURL *noSoundFileURL=[NSURL fileURLWithPath:
                           [[NSBundle mainBundle] 
                            pathForResource:@"norecording" ofType:@"wav"]];
    self.audioPlayer =  [[AVAudioPlayer alloc] 
                         initWithContentsOfURL:noSoundFileURL error:nil];

    
    //Setup the music player
	self.musicPlayer=[MPMusicPlayerController iPodMusicPlayer]; 

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setAudioRecorder:nil];
    [self setMoviePlayer:nil];
    [self setMusicPlayer:nil];
    [self setToggleFullscreen:nil];
    [self setToggleCamera:nil];
    [self setDisplayImageView:nil];
    [self setDisplayNowPlaying:nil];
    [self setMusicPlayButton:nil];
    [self setRecordButton:nil];
    [self setPopoverController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)playMovie:(id)sender {
    [self.view addSubview:self.moviePlayer.view];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(playMovieFinished:)
                                name:MPMoviePlayerPlaybackDidFinishNotification
                                object:self.moviePlayer];
	    
    if ([self.toggleFullscreen isOn]) {
        [self.moviePlayer setFullscreen:YES animated:YES];
	} 
    
    [self.moviePlayer play];
}

-(void)playMovieFinished:(NSNotification*)theNotification
{
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:self.moviePlayer];
    
    [self.moviePlayer.view removeFromSuperview];
}

- (IBAction)recordAudio:(id)sender {
    if ([self.recordButton.titleLabel.text 
                    isEqualToString:@"Record Audio"]) {
		[self.audioRecorder record];
		[self.recordButton setTitle:@"Stop Recording" 
					  forState:UIControlStateNormal];
	} else {
		[self.audioRecorder stop];
 		[self.recordButton setTitle:@"Record Audio" 
					  forState:UIControlStateNormal];
        // Load the new sound in the audioPlayer for playback
        NSURL *soundFileURL=[NSURL fileURLWithPath: 
                   [NSTemporaryDirectory() 
                    stringByAppendingString:@"sound.caf"]];
        self.audioPlayer =  [[AVAudioPlayer alloc] 
                        initWithContentsOfURL:soundFileURL error:nil];
	}
}

- (IBAction)playAudio:(id)sender {
//    self.audioPlayer.delegate=self;
	[self.audioPlayer play];
}

/*
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player 
                       successfully:(BOOL)flag {
    player=nil;
}
 */

- (IBAction)chooseImage:(id)sender {
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    
    if ([self.toggleCamera isOn]) {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
	} else {
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
	imagePicker.delegate=self;
    
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    popoverController=[[UIPopoverController alloc]
                       initWithContentViewController:imagePicker];
    [popoverController presentPopoverFromRect:((UIButton *)sender).frame 
                                       inView:self.view 
                     permittedArrowDirections:UIPopoverArrowDirectionAny 
                                     animated:YES];
    
//    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)applyFilter:(id)sender {
    CIImage *imageToFilter;
    imageToFilter=[[CIImage alloc] 
                   initWithImage:self.displayImageView.image];
    
    CIFilter *activeFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [activeFilter setDefaults];
    [activeFilter setValue: [NSNumber numberWithFloat: 0.75] 
                    forKey: @"inputIntensity"];
    [activeFilter setValue: imageToFilter forKey: @"inputImage"];
    CIImage *filteredImage=[activeFilter valueForKey: @"outputImage"];
    
    // This varies from the book, because the iOS beta is broken
    CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionary]];
    CGImageRef cgImage = [context createCGImage:filteredImage fromRect:[imageToFilter extent]];
    UIImage *myNewImage = [UIImage imageWithCGImage:cgImage];
    //   UIImage *myNewImage = [UIImage imageWithCIImage:filteredImage];
    self.displayImageView.image = myNewImage;
    CGImageRelease(cgImage);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissModalViewControllerAnimated:YES];
    self.displayImageView.image=[info objectForKey:
                                 UIImagePickerControllerOriginalImage];
}

- (IBAction)chooseMusic:(id)sender {
    MPMediaPickerController *musicPicker;
	
	[self.musicPlayer stop];
	self.displayNowPlaying.text=@"No Song Playing";
	[self.musicPlayButton setTitle:@"Play Music" 
					forState:UIControlStateNormal];
	
	musicPicker = [[MPMediaPickerController alloc] 
				   initWithMediaTypes: MPMediaTypeMusic];
	
	musicPicker.prompt = @"Choose Songs to Play" ;
	musicPicker.allowsPickingMultipleItems = YES;
	musicPicker.delegate = self;
	
	[self presentModalViewController:musicPicker animated:YES];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[musicPlayer setQueueWithItemCollection: mediaItemCollection];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)playMusic:(id)sender {
    if ([self.musicPlayButton.titleLabel.text 
                    isEqualToString:@"Play Music"]) {
		[self.musicPlayer play];
		[self.musicPlayButton setTitle:@"Pause Music" 
						forState:UIControlStateNormal];
		self.displayNowPlaying.text=[self.musicPlayer.nowPlayingItem 
						 valueForProperty:MPMediaItemPropertyTitle];
        
	} else {
        
		[self.musicPlayer pause];
		[self.musicPlayButton setTitle:@"Play Music" 
						forState:UIControlStateNormal];
		self.displayNowPlaying.text=@"No Song Playing";
	}
}


@end
