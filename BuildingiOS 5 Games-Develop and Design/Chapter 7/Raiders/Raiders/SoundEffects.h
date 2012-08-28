//
//  SoundEffects.h
//  Raiders
//
//  Created by James Sugrue on 3/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffects : NSObject {
    SystemSoundID explosionEffect;
}

+ (SoundEffects *)sharedSoundEffects;

- (void)playExplosionEffect;

@end
