//
//  BBRock.h
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@interface BBRock : BBMobileObject {
	CGFloat * verts;
	CGFloat * colors;
	NSInteger smashCount;
}

@property (assign) NSInteger smashCount;

+ (BBRock*)randomRock;
+ (BBRock*)randomRockWithScale:(NSRange)scaleRange;
- (id) init;
- (void) dealloc;
- (void)awake;
- (void)smash;
- (void)update;

// 7 methods


@end
