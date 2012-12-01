//
//  IPodMusicController.h
//  SpaceRocks
//
//  Created by Eric Wing on 8/17/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface IPodMusicController : NSObject <MPMediaPickerControllerDelegate>
{
}

+ (IPodMusicController*) sharedMusicController;
- (void) startApplication;
- (void) presentMediaPicker:(UIViewController*)current_view_controller;

@end
