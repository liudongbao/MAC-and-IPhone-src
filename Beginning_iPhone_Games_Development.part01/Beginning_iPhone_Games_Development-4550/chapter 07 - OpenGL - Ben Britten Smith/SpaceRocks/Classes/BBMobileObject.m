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
	translation.x += speed.x;
	translation.y += speed.y;
	translation.z += speed.z;
	
	rotation.x += rotationalSpeed.x;
	rotation.y += rotationalSpeed.y;
	rotation.z += rotationalSpeed.z;
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
