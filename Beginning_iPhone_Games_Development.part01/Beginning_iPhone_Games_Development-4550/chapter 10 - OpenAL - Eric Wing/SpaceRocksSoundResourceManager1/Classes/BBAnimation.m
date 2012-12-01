//
//  BBAnimation.m
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBAnimation.h"


@implementation BBAnimation
- (id) initWithAtlasKeys:(NSArray*)keys loops:(BOOL)loops speed:(NSInteger)speed
{
	self = [super init];
	if (self != nil) {
		self.mesh = [[BBMaterialController sharedMaterialController] animationFromAtlasKeys:keys];
		[(BBAnimatedQuad*)mesh setSpeed:speed];
		[(BBAnimatedQuad*)mesh setLoops:loops];
	}
	return self;
}

-(void)awake
{
	
}

// called once every frame
-(void)update
{
	[super update];
	[(BBAnimatedQuad*)mesh updateAnimation];
	if ([(BBAnimatedQuad*)mesh didFinish]) {
		[[BBSceneController sharedSceneController] removeObjectFromScene:self];	
	}	
}
@end
