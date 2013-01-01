//
//  PolygonSprite.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/20/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import "PolygonSprite.h"

@implementation PolygonSprite

@synthesize body = _body;
@synthesize original = _original;
@synthesize centroid = _centroid;


+(id)spriteWithFile:(NSString *)filename body:(b2Body *)body  original:(BOOL)original
{
    return [[[self alloc]initWithFile:filename body:body original:original] autorelease];
}
+(id)spriteWithTexture:(CCTexture2D *)texture body:(b2Body *)body  original:(BOOL)original
{
    return [[[self alloc]initWithTexture:texture body:body original:original] autorelease];
}
+(id)spriteWithWorld:(b2World *)world
{
    return [[[self alloc]initWithWorld:world] autorelease];
}
-(id)initWithFile:(NSString*)filename body:(b2Body*)body  original:(BOOL)original
{
    NSAssert(filename != nil, @"Invalid filename for sprite");
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
    return [self initWithTexture:texture body:body original:original];
}
-(id)initWithTexture:(CCTexture2D*)texture body:(b2Body*)body original:(BOOL)original
{
    // gather all the vertices from our Box2D shape
    b2Fixture *originalFixture = body->GetFixtureList();
    b2PolygonShape *shape = (b2PolygonShape*)originalFixture->GetShape();
    int vertexCount = shape->GetVertexCount();
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:vertexCount];
    for(int i = 0; i < vertexCount; i++) {
        CGPoint p = ccp(shape->GetVertex(i).x * PTM_RATIO, shape->GetVertex(i).y * PTM_RATIO);
        [points addObject:[NSValue valueWithCGPoint:p]];
    }
    
    if ((self = [super initWithPoints:points andTexture:texture]))
    {
        _body = body;
        _body->SetUserData(self);
        _original = original;
        // gets the center of the polygon
        _centroid = self.body->GetLocalCenter();
        // assign an anchor point based on the center
        self.anchorPoint = ccp(_centroid.x * PTM_RATIO / texture.contentSize.width, 
                               _centroid.y * PTM_RATIO / texture.contentSize.height);
    }
    return self;
}
-(id)initWithWorld:(b2World *)world
{
    //nothing to do here
    return nil;
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    _body->SetTransform(b2Vec2(position.x/PTM_RATIO,position.y/PTM_RATIO), _body->GetAngle());
}

-(b2Body*)createBodyForWorld:(b2World *)world position:(b2Vec2)position rotation:(float)rotation vertices:(b2Vec2*)vertices vertexCount:(int32)count density:(float)density friction:(float)friction restitution:(float)restitution
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = position;
    bodyDef.angle = rotation;
    b2Body *body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    fixtureDef.filter.categoryBits = 0;
    fixtureDef.filter.maskBits = 0;
    //fixtureDef.isSensor = YES;
    
    b2PolygonShape shape;
    shape.Set(vertices, count);
    fixtureDef.shape = &shape;
    body->CreateFixture(&fixtureDef);
    
    return body;
}

-(void)activateCollisions
{
    b2Fixture *fixture = _body->GetFixtureList();
    b2Filter filter = fixture->GetFilterData();
    filter.categoryBits = 0x0001;
    filter.maskBits = 0x0001;
    fixture->SetFilterData(filter);
}

-(void)deactivateCollisions
{
    b2Fixture *fixture = _body->GetFixtureList();
    b2Filter filter = fixture->GetFilterData();
    filter.categoryBits = 0;
    filter.maskBits = 0;
    fixture->SetFilterData(filter);
}

-(CGAffineTransform) nodeToParentTransform
{
    b2Vec2 pos  = _body->GetPosition();
    
    float x = pos.x * PTM_RATIO;
    float y = pos.y * PTM_RATIO;
    
    if ( !isRelativeAnchorPoint_ ) {
        x += anchorPointInPoints_.x;
        y += anchorPointInPoints_.y;
    }
    
    // Make matrix
    float radians = _body->GetAngle();
    float c = cosf(radians);
    float s = sinf(radians);
    
    if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
        x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
        y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
    }
    
    // Rot, Translate Matrix
    transform_ = CGAffineTransformMake( c,  s,
                                       -s,c,
                                       x,y );
    
    return transform_;
}

@end
