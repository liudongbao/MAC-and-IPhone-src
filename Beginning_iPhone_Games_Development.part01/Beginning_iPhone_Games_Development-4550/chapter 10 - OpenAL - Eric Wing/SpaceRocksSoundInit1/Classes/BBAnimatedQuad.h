//
//  BBAnimatedQuad.h
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBTexturedQuad.h"


@interface BBAnimatedQuad : BBTexturedQuad {
	NSMutableArray * frameQuads;
	CGFloat speed;
	NSTimeInterval elapsedTime;
	BOOL loops;
	BOOL didFinish;
}

@property (assign) CGFloat speed;
@property (assign) BOOL loops;
@property (assign) BOOL didFinish;

- (id) init;
- (void) dealloc;
- (void)addFrame:(BBTexturedQuad*)aQuad;
- (void)setFrame:(BBTexturedQuad*)quad;
- (void)updateAnimation;

// 5 methods

@end
