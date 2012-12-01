//
//  BBMobileObject.m
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMobileObject.h"

@implementation BBMobileObject

@synthesize speed,rotationalSpeed;

// called once every frame, sublcasses need to remember to call this
// method via [super update]
-(void)update
{
	CGFloat deltaTime = [[BBSceneController sharedSceneController] deltaTime];
	translation.x += speed.x * deltaTime;
	translation.y += speed.y * deltaTime;
	translation.z += speed.z * deltaTime;
	
	rotation.x += rotationalSpeed.x * deltaTime;
	rotation.y += rotationalSpeed.y * deltaTime;
	rotation.z += rotationalSpeed.z * deltaTime;
	[self checkArenaBounds];
	[super update];
}

-(void)checkArenaBounds
{
	if (translation.x > (240.0 + CGRectGetWidth(self.meshBounds)/2.0)) translation.x -= 480.0 + CGRectGetWidth(self.meshBounds); 
	if (translation.x < (-240.0 - CGRectGetWidth(self.meshBounds)/2.0)) translation.x += 480.0 + CGRectGetWidth(self.meshBounds); 

	if (translation.y > (160.0 + CGRectGetHeight(self.meshBounds)/2.0)) translation.y -= 320.0 + CGRectGetHeight(self.meshBounds); 
	if (translation.y < (-160.0 - CGRectGetHeight(self.meshBounds)/2.0)) translation.y += 320.0 + CGRectGetHeight(self.meshBounds); 
}

@end
