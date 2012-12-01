//
//  AudioController.m
//  Asteroids
//
//  Created by Scott Penberthy on 3/12/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "AudioController.h"

@implementation AudioController


- (id) init
{
	self = [super init];
	if (self) {
		sounds = malloc(sizeof(SystemSoundID)*kTotalSounds);
		bzero(sounds,sizeof(SystemSoundID)*kTotalSounds);
		reload = 0;
		[self loadSound: @"explode1" withKey: kSoundExplode1];
		[self loadSound: @"explode2" withKey: kSoundExplode2];
		[self loadSound: @"explode3" withKey: kSoundExplode3];
		[self loadSound: @"fire"     withKey: kSoundFire];
		[self loadSound: @"sfire"    withKey: kSoundSaucerFire];
		[self loadSound: @"saucer1"  withKey: kSoundSaucer1];
		[self loadSound: @"saucer2"  withKey: kSoundSaucer2];
		[self loadSound: @"thrust"   withKey: kSoundThrust];
		[self loadSound: @"alert"	 withKey: kSoundAlert];
	}
	return self;
}

- (void) loadSound: (NSString *) name withKey: (uint) key
{
	if (key >= kTotalSounds) {
		printf("Bad sound key %d, ignoring.\n",key);
		return;
	}
	SystemSoundID sid;
	CFURLRef url;
	sid = 0;
	// Get the URL to the sound file to play
	url = CFBundleCopyResourceURL(CFBundleGetMainBundle(),(CFStringRef) name,CFSTR("aif"),NULL);
	AudioServicesCreateSystemSoundID(url, &sid);
	sounds[key] = sid;
}

- (void) tic: (NSTimeInterval) dt
{
	int key = [AsteroidsModel getState: kSound];
	if (key != kSoundNone && reload <= 0) {
		[AsteroidsModel setState: kSound to: kSoundNone];
		if (key >= 0 && key < kTotalSounds) {
			printf("Playing sound %d\n",key);
			AudioServicesPlaySystemSound(sounds[key]);
		}
		else {
			printf("Bad sound key %d, not played.\n", key);
		}
		reload = kSoundReload;
	}
	else if (reload) {
		reload -= dt;
		if (reload < 0) reload = 0.0;
	}
}

- (void)dealloc {
	if (sounds) {
		for (int i=0; i < kTotalSounds; i++) {
			SystemSoundID sid = sounds[i];
			if (sid) AudioServicesDisposeSystemSoundID(sid);
		}
		free(sounds);
	}
    [super dealloc];
}
		

@end
