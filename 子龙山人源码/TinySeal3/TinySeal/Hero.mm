//
//  Hero.mm
//  TinySeal
//
//  Created by Ray Wenderlich on 6/17/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "Hero.h"

@implementation Hero
@synthesize awake = _awake;

- (void)createBody {
    
    
    float radius = 16.0f;
    CGSize size = [[CCDirector sharedDirector] winSize];
    int screenH = size.height;
    
    CGPoint startPosition = ccp(0, screenH/2+radius);
    
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    bd.linearDamping = 0.1f;
    bd.fixedRotation = true;
    bd.position.Set(startPosition.x/PTM_RATIO, startPosition.y/PTM_RATIO);
    _body = _world->CreateBody(&bd);
    
    b2CircleShape shape;
    shape.m_radius = radius/PTM_RATIO;
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
    fd.restitution = 0.0f;
    fd.friction = 0.2;
    
    _body->CreateFixture(&fd);
    
}

- (id)initWithWorld:(b2World *)world {
    
    if ((self = [super initWithSpriteFrameName:@"seal1.png"])) {
        _world = world;
        [self createBody];
        
        _normalAnim = [[CCAnimation alloc] init];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"seal1.png"]];
        [_normalAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"seal2.png"]];
        _normalAnim.delay = 0.1;
    }
    return self;
    
}

- (void)update {
    
    self.position = ccp(_body->GetPosition().x*PTM_RATIO, _body->GetPosition().y*PTM_RATIO);
    b2Vec2 vel = _body->GetLinearVelocity();
    b2Vec2 weightedVel = vel;
    
    for(int i = 0; i < NUM_PREV_VELS; ++i) {
        weightedVel += _prevVels[i];
    }
    weightedVel = b2Vec2(weightedVel.x/NUM_PREV_VELS, weightedVel.y/NUM_PREV_VELS);    
    _prevVels[_nextVel++] = vel;
    if (_nextVel >= NUM_PREV_VELS) _nextVel = 0;
    
    float angle = ccpToAngle(ccp(weightedVel.x, weightedVel.y));     
    if (_awake) {   
        self.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
    }
}
- (void) wake {
    _awake = YES;
    _body->SetActive(true);
    _body->ApplyLinearImpulse(b2Vec2(1,2), _body->GetPosition());
}

- (void) dive {
    _body->ApplyForce(b2Vec2(5,-50),_body->GetPosition());
}

- (void) limitVelocity {    
    if (!_awake) return;
    
    const float minVelocityX = 5;
    const float minVelocityY = -40;
    b2Vec2 vel = _body->GetLinearVelocity();
    if (vel.x < minVelocityX) {
        vel.x = minVelocityX;
    }
    if (vel.y < minVelocityY) {
        vel.y = minVelocityY;
    }
    _body->SetLinearVelocity(vel);
}

- (void)runNormalAnimation {
    if (_normalAnimate || !_awake) return;
    _normalAnimate = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:_normalAnim]];
    [self runAction:_normalAnimate];
}

- (void)runForceAnimation {
    [_normalAnimate stop];
    _normalAnimate = nil;
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"seal_downhill.png"]];
}

- (void)nodive {
    [self runNormalAnimation];
}

@end
