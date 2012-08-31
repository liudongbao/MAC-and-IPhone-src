//
//  HelloWorldLayer.m
//  ParticleEffects
//
//  Created by Steffen Itterheim on 23.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"
#import "ParticleEffectSelfMade.h"

@interface HelloWorld (PrivateMethods)
-(void) runEffect;
@end

@implementation HelloWorld
+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(20, 20, 50, 255)];
		[self addChild:layer z:-1];
		
		label = [CCLabelTTF labelWithString:@"Hello Particles" fontName:@"Marker Felt" fontSize:50];
		CGSize size = [[CCDirector sharedDirector] winSize];
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
		case ParticleTypeDesignedFX:
			// by using ARCH_OPTIMAL_PARTICLE_SYSTEM either the CCQuadParticleSystem or CCPointParticleSystem class is
			// used depending on the current target.
			system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"designed-fx.plist"];
			break;
		case ParticleTypeDesignedFX2:
			// uses a plist with the texture already embedded
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx2.plist"];
			system.positionType = kCCPositionTypeFree;
			break;
		case ParticleTypeDesignedFX3:
			// same effect but different texture (scaled down by Particle Designer)
			system = [CCParticleSystemQuad particleWithFile:@"designed-fx3.plist"];
			system.positionType = kCCPositionTypeFree;
			break;
		case ParticleTypeSelfMade:
			system = [ParticleEffectSelfMade node];
			break;
		
		default:
			// do nothing
			break;
	}

	CGSize winSize = [[CCDirector sharedDirector] winSize];
	system.position = CGPointMake(winSize.width / 2, winSize.height / 2);
	[self addChild:system z:1 tag:1];
	
	[label setString:NSStringFromClass([system class])];
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
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
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
