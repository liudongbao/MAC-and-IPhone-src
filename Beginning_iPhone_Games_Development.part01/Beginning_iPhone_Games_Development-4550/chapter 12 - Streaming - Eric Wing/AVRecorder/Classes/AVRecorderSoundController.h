//
//  AVRecorderSoundController.h
//  AVRecorder
//
//  Created by Eric Wing on 8/19/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AVRecorderSoundController : NSObject <AVAudioSessionDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
	AVAudioPlayer* avPlayer;
	AVAudioRecorder* avRecorder;
	BOOL playing;
	BOOL recording;	
}

@property(nonatomic, retain) AVAudioPlayer* avPlayer;
@property(nonatomic, retain) AVAudioRecorder* avRecorder;
@property(nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property(nonatomic, assign, readonly, getter=isRecording) BOOL recording;


- (void) togglePlay;
- (void) toggleRecord;


@end
