//
//  AudioController.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/12/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defs.h"
#import "AsteroidsModel.h"
#include <AudioToolbox/AudioToolbox.h>

@interface AudioController : NSObject {
	SystemSoundID *sounds;
	CGFloat reload;
}

- (void) loadSound: (NSString *) name withKey: (uint) key;
- (void) tic: (NSTimeInterval) dt;

@end
