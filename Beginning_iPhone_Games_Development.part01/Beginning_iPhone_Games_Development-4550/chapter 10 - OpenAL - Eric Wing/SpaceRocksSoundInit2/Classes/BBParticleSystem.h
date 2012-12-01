//
//  BBParticleSystem.h
//  SkateDude
//
//  Created by ben smith on 28/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneObject.h"
#import "BBPoint.h"

@class BBParticle;

@interface BBParticleSystem : BBSceneObject {
	NSMutableArray * activeParticles;
	NSMutableArray * objectsToRemove;
	NSMutableArray * particlePool;
	GLfloat * uvCoordinates;
	GLfloat * vertexes;
	NSString * materialKey;	
	NSInteger vertexIndex;
	BOOL emit;
	CGFloat minU;
	CGFloat maxU;
	CGFloat minV;
	CGFloat maxV;
	
	NSInteger emitCounter;
	
	BBRange emissionRange;
	BBRange sizeRange;
	BBRange growRange;

	BBRange xVelocityRange;
	BBRange yVelocityRange;
	
	BBRange lifeRange;
	BBRange decayRange;
}

@property (retain) NSString * materialKey;

@property (assign) BOOL emit;
@property (assign) NSInteger emitCounter;

@property (assign) BBRange emissionRange;
@property (assign) BBRange sizeRange;
@property (assign) BBRange growRange;
@property (assign) BBRange xVelocityRange;
@property (assign) BBRange yVelocityRange;

@property (assign) BBRange lifeRange;
@property (assign) BBRange decayRange;

- (BOOL)activeParticles;
- (id)init;
- (void)dealloc;
- (void)addVertex:(CGFloat)x y:(CGFloat)y u:(CGFloat)u v:(CGFloat)v;
- (void)awake;
- (void)buildVertexArrays;
- (void)clearDeadQueue;
- (void)emitNewParticles;
- (void)removeChildParticle:(BBParticle*)particle;
- (void)render;
- (void)setDefaultSystem;
- (void)setParticle:(NSString*)atlasKey;
- (void)update;

// 13 methods


@end
