//
//  Watermelon.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/21/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import "Watermelon.h"


@implementation Watermelon

-(id)initWithWorld:(b2World *)world
{
    int32 count = 7;
    NSString *file = @"watermelon.png";
    b2Vec2 vertices[] = {
        b2Vec2(5.0/PTM_RATIO,15.0/PTM_RATIO),
        b2Vec2(18.0/PTM_RATIO,7.0/PTM_RATIO),
        b2Vec2(32.0/PTM_RATIO,5.0/PTM_RATIO),
        b2Vec2(48.0/PTM_RATIO,7.0/PTM_RATIO),
        b2Vec2(60.0/PTM_RATIO,14.0/PTM_RATIO),
        b2Vec2(34.0/PTM_RATIO,59.0/PTM_RATIO),
        b2Vec2(28.0/PTM_RATIO,59.0/PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld:world position:b2Vec2(screen.width/2/PTM_RATIO,screen.height/2/PTM_RATIO) rotation:0 vertices:vertices vertexCount:count density:5.0 friction:0.2 restitution:0.2];
    
    if ((self = [super initWithFile:file body:body original:YES]))
    {
    }
    return self;
}

@end
