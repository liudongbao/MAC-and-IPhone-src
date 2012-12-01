//
//  Terrain.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@class HelloWorldLayer;

#define kMaxHillKeyPoints 1000
#define kHillSegmentWidth 5
#define kMaxHillVertices 4000
#define kMaxBorderVertices 800 

@interface Terrain : CCNode {
    int _offsetX;
    CGPoint _hillKeyPoints[kMaxHillKeyPoints];
    CCSprite *_stripes;
    
    int _fromKeyPointI;
    int _toKeyPointI;
    
    int _nHillVertices;
    CGPoint _hillVertices[kMaxHillVertices];
    CGPoint _hillTexCoords[kMaxHillVertices];
    int _nBorderVertices;
    CGPoint _borderVertices[kMaxBorderVertices];
    
    b2World *_world;
    b2Body *_body;
    GLESDebugDraw * _debugDraw;
    
    CCSpriteBatchNode * _batchNode;
}

@property (retain) CCSprite * stripes;
@property (retain) CCSpriteBatchNode * batchNode;

- (void) setOffsetX:(float)newOffsetX;
- (id)initWithWorld:(b2World *)world;

@end
