//
//  SoundEffects.m
//  Raiders
//
//  Created by James Sugrue on 3/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "SoundEffects.h"
#import "SynthesizeSingleton.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SoundEffects (private)

- (void)initEffects;

@end

@implementation SoundEffects

SYNTHESIZE_SINGLETON_FOR_CLASS(SoundEffects);

- (id)init {
    self = [super init];
    if(self != nil) {
        [self initEffects];
    }
    return self;
}

- (void)initEffects {
    CFBundleRef mainBundle = CFBundleGetMainBundle ();
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL(mainBundle, CFSTR("bang2"), CFSTR("wav"), NULL);
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &explosionEffect);
}

- (void)playExplosionEffect {
    AudioServicesPlaySystemSound(explosionEffect);
}

@end
