//
//  MoreBetterAnimations.m
//
//  Created by PJ Cabrera on 1/8/10.
//  Copyright 2010 PJ Cabrera. All rights reserved.
//

#import "MoreBetterAnimations.h"

@implementation MoreBetterAnimations

@synthesize frameInterval;

- (MoreBetterAnimations *)init {
    if (self = [super init]) {
        _frameCounter = 0;
        _repeatCounter = 0;
        _timeElapsed = 0;
        _displayLink= [CADisplayLink displayLinkWithTarget:self 
                selector:@selector(changeAnimationImage) ];
    }
    return self;
}

- (NSInteger)frameInterval {
	if (!_displayLink)   {
        _displayLink= [CADisplayLink displayLinkWithTarget:self 
                selector:@selector(changeAnimationImage) ];
    }
    return _displayLink.frameInterval;
}

- (void)setFrameInterval:(NSInteger)newValue {
    if (!_displayLink)   {
        _displayLink= [CADisplayLink displayLinkWithTarget:self 
                selector:@selector(changeAnimationImage) ];
    }
    if ( 1 > newValue) {
        _displayLink.frameInterval = 1;
    } else if ( 4 < newValue) {
        _displayLink.frameInterval = 4;
    } else {
        _displayLink.frameInterval= newValue;
    }
}

- (void)stopAnimating {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink= nil;
    }
}

- (void)startAnimating {
    if (self.animationDuration > 0 && self.animationImages && 
                [self.animationImages count] > 0) {
        _frameCounter = 0;
        _repeatCounter = 0;
        _timeElapsed = 0;

        if (!_displayLink)   {
            _displayLink= [CADisplayLink displayLinkWithTarget:self 
                    selector:@selector(changeAnimationImage) ];
        }
        [_displayLink addToRunLoop: [NSRunLoop currentRunLoop] 
                                         forMode: NSDefaultRunLoopMode];
    }
}

- (void)changeAnimationImage {
    self.image = [self.animationImages objectAtIndex:frameCounter++];
    _timeElapsed += _displayLink.duration;
    
    if ( (_timeElapsed >= self.animationDuration || 
                _frameCounter >= self.animationImages.length) && 
                (0 < self.animationRepeatCount  && 
                _repeatCounter <= self.animationRepeatCount) ) {
        _repeatCounter++;
        _frameCounter = 0;
    }
    if (_repeatCounter >= self.animationRepeatCount) {
        [self stopAnimating];
    }
}

@end
