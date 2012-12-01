//
//  BBAnimatedQuad.m
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBAnimatedQuad.h"
#import "BBSceneController.h"



@implementation BBAnimatedQuad

@synthesize speed,loops,didFinish;
- (id) init
{
	self = [super init];
	if (self != nil) {
		self.speed = 12; // 12 fps
		self.loops = NO;
		self.didFinish = NO;
		elapsedTime = 0.0;
	}
	return self;
}

-(void)addFrame:(BBTexturedQuad*)aQuad
{
	if (frameQuads == nil) frameQuads = [[NSMutableArray alloc] init];
	[frameQuads addObject:aQuad];
}

-(void)updateAnimation
{
	elapsedTime += [BBSceneController sharedSceneController].deltaTime;
	NSInteger frame = (int)(elapsedTime/(1.0/speed));
	if (loops) frame = frame % [frameQuads count];
	if (frame >= [frameQuads count]) {
		didFinish = YES;
		return;
	}
	[self setFrame:[frameQuads objectAtIndex:frame]];
}

-(void)setFrame:(BBTexturedQuad*)quad
{
	self.uvCoordinates = quad.uvCoordinates;
	self.materialKey = quad.materialKey;
}

- (void) dealloc
{
	uvCoordinates = 0;
	[super dealloc];
}









@end
