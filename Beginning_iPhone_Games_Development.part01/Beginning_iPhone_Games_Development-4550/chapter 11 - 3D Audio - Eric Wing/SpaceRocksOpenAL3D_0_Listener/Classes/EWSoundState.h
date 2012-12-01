//
//  EWSoundState.h
//  SpaceRocks
//
//  Created by Eric Wing on 7/27/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@interface EWSoundState : NSObject
{
	ALfloat gainLevel;
}

@property(nonatomic, assign) ALfloat gainLevel;

// virtual functions which should be overridden by subclasses
- (void) applyState;
- (void) update;

@end
