//
//  EWSoundState.m
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "EWSoundState.h"


@implementation EWSoundState

@synthesize gainLevel;
@synthesize objectPosition;

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		gainLevel = 1.0f;
		objectPosition = BBPointMake(0.0, 0.0, 0.0);
	}
	return self;
}

- (void) applyState
{
	
}

- (void) update
{
	
}

@end
