//
//  ParticleEffectSelfMade.h
//  ParticleEffects
//
//  Created by Steffen Itterheim on 24.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Depending on the targeted device the ParticleEffectSelfMade class will either derive
// from CCPointParticleSystem or CCQuadParticleSystem (preferred for iOS 3rd and 4th Generation)
@interface ParticleEffectSelfMade : ARCH_OPTIMAL_PARTICLE_SYSTEM 
{

}

@end
