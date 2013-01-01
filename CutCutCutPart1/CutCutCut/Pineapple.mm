//
//  Pineapple.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/16/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import "Pineapple.h"


@implementation Pineapple

-(id)initWithWorld:(b2World *)world
{
    int32 count = 7;
    NSString *file = @"pineapple.png";
    b2Vec2 vertices[] = {
        b2Vec2(61.0/PTM_RATIO,64.0/PTM_RATIO),
        b2Vec2(39.0/PTM_RATIO,64.0/PTM_RATIO),
        b2Vec2(0.0/PTM_RATIO,23.0/PTM_RATIO),
        b2Vec2(0.0/PTM_RATIO,10.0/PTM_RATIO),
        b2Vec2(11.0/PTM_RATIO,0.0/PTM_RATIO),
        b2Vec2(29.0/PTM_RATIO,0.0/PTM_RATIO),
        b2Vec2(64.0/PTM_RATIO,39.0/PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world position:b2Vec2(screen.width/2/PTM_RATIO,screen.height/2/PTM_RATIO) rotation:0 vertices:vertices vertexCount:count density:5.0 friction:0.2 restitution:0.2];
    
    if ((self = [super initWithFile:file body:body original:YES]))
    {
    }
    return self;
}

@end
