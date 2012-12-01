//
//  BetterAnimations.m
//
//  Created by PJ Cabrera on 1/8/10.
//  Copyright 2010 PJ Cabrera. All rights reserved.
//

#import "BetterAnimations.h"

@implementation BetterAnimations

@synthesize animationInterval = _animationInterval;

- (BetterAnimations *)init {
    if (self = [super init]) {
        _animationInterval = 1.0 / 30.0;
		_frameCounter = 0;
		_repeatCounter = 0;
		_timeElapsed = 0;
		_theTimer = nil;
	}
    return self;
}

- (void)setAnimationInterval:(NSTimeInterval)newValue {
    if ( (1.0 / 5.0) < newValue) {
        _animationInterval = 1.0 / 5.0;
    } else if ( (1.0 / 60.0) > newValue) {
        _animationInterval = 1.0 / 60.0;
    } else {
        _animationInterval = newValue;
    }
}

- (void)stopAnimating {
    if (_theTimer) {
        [_theTimer invalidate];
        _theTimer = nil;
    }
}

- (void)startAnimating {
	if (self.animationDuration > 0 && self.animationImages && [self.animationImages count] > 0) {
		_frameCounter = 0;
		_repeatCounter = 0;
		_timeElapsed = 0;

		_theTimer = [NSTimer timerWithTimeInterval:_animationInterval 
											target:self 
										  selector:@selector(changeAnimationImage) 
										  userInfo:nil 
										   repeats:(self.animationRepeatCount > 0)];
	}
}

- (void)changeAnimationImage {
	self.image = [self.animationImages objectAtIndex:frameCounter++];
	_timeElapsed += _animationInterval;
	
	if ( (_timeElapsed >= self.animationDuration || _frameCounter >= self.animationImages.length) && 
			(0 < self.animationRepeatCount  && _repeatCounter <= self.animationRepeatCount) ) {
		_repeatCounter++;
		_frameCounter = 0;
	}
	if (_repeatCounter >= self.animationRepeatCount) {
		[theTimer invalidate];
	}
}

@end
