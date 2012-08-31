//
//  HelloWorldLayer.m
//  ParticleEffects
//
//  Created by Steffen Itterheim on 23.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"

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
		label = [CCLabelTTF labelWithString:@"Hello Particles" fontName:@"Marker Felt" fontSize:64];
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
			
		default:
			// do nothing
			break;
	}

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
