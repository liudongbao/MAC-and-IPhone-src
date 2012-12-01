//
//  AVPlaybackSoundController.h
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AVPlaybackSoundController : NSObject <AVAudioSessionDelegate, AVAudioPlayerDelegate>
{
	AVAudioPlayer* avMusicPlayer;
	AVAudioPlayer* avSpeechPlayer;
}

@property(nonatomic, retain) AVAudioPlayer* avMusicPlayer;
@property(nonatomic, retain) AVAudioPlayer* avSpeechPlayer;

- (void) playOrPauseSpeech;
- (void) rewindSpeech;
- (void) fastForwardSpeech;


@end
