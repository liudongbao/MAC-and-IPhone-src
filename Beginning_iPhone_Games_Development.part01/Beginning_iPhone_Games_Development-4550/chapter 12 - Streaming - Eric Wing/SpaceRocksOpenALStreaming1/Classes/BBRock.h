//
//  BBRock.h
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@class BBParticleSystem;

@interface BBRock : BBMobileObject {
	NSInteger smashCount;
	BBParticleSystem * particleEmitter;
	
	BOOL smashed;
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
