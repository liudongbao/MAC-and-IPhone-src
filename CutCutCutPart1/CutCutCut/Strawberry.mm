//
//  Strawberry.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/16/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import "Strawberry.h"


@implementation Strawberry

-(id)initWithWorld:(b2World *)world
{
    int32 count = 7;
    NSString *file = @"strawberry.png";
    b2Vec2 vertices[] = {
        b2Vec2(51.0/PTM_RATIO,5.0/PTM_RATIO),
        b2Vec2(56.0/PTM_RATIO,21.0/PTM_RATIO),
        b2Vec2(54.0/PTM_RATIO,45.0/PTM_RATIO),
        b2Vec2(37.0/PTM_RATIO,62.0/PTM_RATIO),
        b2Vec2(8.0/PTM_RATIO,48.0/PTM_RATIO),
        b2Vec2(12.0/PTM_RATIO,24.0/PTM_RATIO),
        b2Vec2(34.0/PTM_RATIO,5.0/PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world position:b2Vec2(screen.width/2/PTM_RATIO,screen.height/2/PTM_RATIO) rotation:0 vertices:vertices vertexCount:count density:5.0 friction:0.2 restitution:0.2];

    if ((self = [super initWithFile:file body:body original:YES]))
    {
    }
    return self;
}

@end
