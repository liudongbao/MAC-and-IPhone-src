//
//  PolygonSprite.h
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/20/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "PRFilledPolygon.h"

#define PTM_RATIO 32

@interface PolygonSprite : PRFilledPolygon {
    b2Body *_body;
    BOOL _original;
    b2Vec2 _centroid;
}

@property(nonatomic,assign)b2Body *body;
@property(nonatomic,readwrite)BOOL original;
@property(nonatomic,readwrite)b2Vec2 centroid;


-(id)initWithTexture:(CCTexture2D*)texture body:(b2Body*)body original:(BOOL)original;
-(id)initWithFile:(NSString*)filename body:(b2Body*)body original:(BOOL)original;
+(id)spriteWithFile:(NSString*)filename body:(b2Body*)body original:(BOOL)original;
+(id)spriteWithTexture:(CCTexture2D*)texture body:(b2Body*)body original:(BOOL)original;
-(id)initWithWorld:(b2World*)world;
+(id)spriteWithWorld:(b2World*)world;
-(b2Body*)createBodyForWorld:(b2World*)world position:(b2Vec2)position rotation:(float)rotation vertices:(b2Vec2*)vertices vertexCount:(int32)count density:(float)density friction:(float)friction restitution:(float)restitution;
-(void)activateCollisions;
-(void)deactivateCollisions;




@end
