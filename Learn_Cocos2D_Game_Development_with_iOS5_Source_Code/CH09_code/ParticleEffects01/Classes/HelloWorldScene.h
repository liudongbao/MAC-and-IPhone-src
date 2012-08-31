//
//  HelloWorldLayer.h
//  ParticleEffects
//
//  Created by Steffen Itterheim on 23.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
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
	
	ParticleTypes_MAX,
} ParticleTypes;

@interface HelloWorld : CCLayer
{
	CCLabelTTF* label;
	ParticleTypes particleType;
	bool touchesMoved;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
