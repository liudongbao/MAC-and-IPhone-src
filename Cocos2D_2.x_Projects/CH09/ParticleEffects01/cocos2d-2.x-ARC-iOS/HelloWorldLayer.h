//
//  HelloWorldLayer.h
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "cocos2d.h"

typedef enum
{
	ParticleTypeExplosion = 0,
	ParticleTypeFire,
	ParticleTypeFireworks,
	ParticleTypeFlower,
	ParticleTypeGalaxy,
	ParticleTypeMeteor,
	ParticleTypeRain,
	ParticleTypeSmoke,
	ParticleTypeSnow,
	ParticleTypeSpiral,
	ParticleTypeSun,
	ParticleTypeSelfMade,
	ParticleTypeDesignedFX,
	ParticleTypeDesignedFX2,
	ParticleTypeDesignedFX3,

	ParticleTypes_MAX,
} ParticleTypes;

@interface HelloWorldLayer : CCLayer
{
	CCLabelTTF* label;
	ParticleTypes particleType;
	BOOL touchesMoved;
}

+(CCScene *) scene;

@end
