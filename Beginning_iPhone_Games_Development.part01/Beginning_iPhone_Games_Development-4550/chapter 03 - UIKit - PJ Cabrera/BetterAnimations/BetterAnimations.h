//
//  BetterAnimations.h
//  IVBricker
//
//  Created by PJ Cabrera on 1/8/10.
//  Copyright 2010 PJ Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BetterAnimations : UIImageView {
    int _frameCounter;
    int _repeatCounter;
	NSTimeInterval _timeElapsed;
    NSTimer *_theTimer;
	NSTimeInterval _animationInterval;
}

@property (nonatomic, readwrite) NSTimeInterval animationInterval;

@end
