//
//  AVPlaybackSoundController.h
//  AVPlayback
//
//  Created by Eric Wing on 7/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AVPlaybackSoundController : NSObject <AVAudioPlayerDelegate>
{
	AVAudioPlayer* avStreamPlayer;
}

@property(nonatomic, retain) AVAudioPlayer* avStreamPlayer;
@property(nonatomic, assign) NSInteger numberOfLoops;
@property(nonatomic, assign) float volume;

- (id) initWithSoundFile:(NSString*)sound_file_basename;

- (void) play;
- (void) pause;
- (void) stop;

@end
