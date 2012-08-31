//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "ParticleEffectSelfMade.h"

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer* layer = [HelloWorldLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		label = [CCLabelTTF labelWithString:@"Hello Particles" fontName:@"Marker Felt" fontSize:48];
		CGSize size = [CCDirector sharedDirector].winSize;
		label.position = CGPointMake(size.width / 2, size.height - label.contentSize.height / 2);
		[self addChild:label];
		
		self.isTouchEnabled = YES;
		
		[self runEffect];
	}
	return self;
}

-(void) runEffect
{
	// remove any previous particle FX
	[self removeChildByTag:1 cleanup:YES];
	
	CCParticleSystem* system;
	
	switch (particleType)
	{
		case ParticleTypeExplosion:
			system = [CCParticleExplosion node];
			break;
		case ParticleTypeFire:
			system = [CCParticleFire node];
			break;
		case ParticleTypeFireworks:
			system = [CCParticleFireworks node];
			break;
		case ParticleTypeFlower:
			system = [CCParticleFlower node];
			break;
		case ParticleTypeGalaxy:
			system = [CCParticleGalaxy node];
			break;
		case ParticleTypeMeteor:
			system = [CCParticleMeteor node];
			break;
		case ParticleTypeRain:
			system = [CCParticleRain node];
			break;
		case ParticleTypeSmoke:
			system = [CCParticleSmoke node];
			break;
		case ParticleTypeSnow:
			system = [CCParticleSnow node];
			break;
		case ParticleTypeSpiral:
			system = [CCParticleSpiral node];
			break;
		case ParticleTypeSun:
			system = [CCParticleSun node];
			break;
		case ParticleTypeSelfMade:
			system = [ParticleEffectSelfMade node];
			break;
		case ParticleTypeDesignedFX:
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx.plist"];
			[label setString:@"Particle Designer FX 1"];
			break;
		case ParticleTypeDesignedFX2:
			// uses a plist with the texture already embedded
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx2.plist"];
			system.positionType = kCCPositionTypeFree;
			[label setString:@"Particle Designer FX 2"];
			break;
		case ParticleTypeDesignedFX3:
			// same effect but different texture (scaled down by Particle Designer)
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx3.plist"];
			system.positionType = kCCPositionTypeFree;
			[label setString:@"Particle Designer FX 3"];
			break;

		default:
			// do nothing
			break;
	}

	CGSize winSize = [CCDirector sharedDirector].winSize;
	system.position = CGPointMake(winSize.width / 2, winSize.height / 2);

	[self addChild:system z:1 tag:1];
	
	if (particleType < ParticleTypeDesignedFX)
	{
		[label setString:NSStringFromClass([system class])];
	}
}

-(void) setNextParticleType
{
	particleType++;
	if (particleType == ParticleTypes_MAX)
	{
		particleType = 0;
	}
}

-(CGPoint) locationFromTouches:(NSSet *)touches
{
	UITouch *touch = touches.anyObject;
	CGPoint touchLocation = [touch locationInView:[touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchesMoved = NO;
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	touchesMoved = YES;
	CCNode* node = [self getChildByTag:1];
	node.position = [self locationFromTouches:touches];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// only switch to next effect if finger didn't move
	if (touchesMoved == NO)
	{
		[self setNextParticleType];
		[self runEffect];
	}
}

@end
