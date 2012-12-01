//
//  Hero.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/17/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#define NUM_PREV_VELS   5
#define PTM_RATIO   32.0

@interface Hero : CCSprite {
    b2World *_world;
    b2Body *_body;
    BOOL _awake;
    
    b2Vec2 _prevVels[NUM_PREV_VELS];
    int _nextVel;
    
    CCAnimation *_normalAnim;
    CCAnimate *_normalAnimate;
}

@property (readonly) BOOL awake;

- (void)wake;
- (void)dive;
- (void)limitVelocity;
- (id)initWithWorld:(b2World *)world;
- (void)update;
- (void)nodive;

@end
