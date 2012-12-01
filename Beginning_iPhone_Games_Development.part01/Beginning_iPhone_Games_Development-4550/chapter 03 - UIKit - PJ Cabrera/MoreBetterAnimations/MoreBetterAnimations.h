//
//  MoreBetterAnimations.h
//  IVBricker
//
//  Created by PJ Cabrera on 1/8/10.
//  Copyright 2010 PJ Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreBetterAnimations : UIImageView {
    int _frameCounter;
    int _repeatCounter;
    NSTimeInterval _timeElapsed;
    CADisplayLink *_displayLink;
}

@property (nonatomic, readwrite) NSInteger frameInterval;

@end
