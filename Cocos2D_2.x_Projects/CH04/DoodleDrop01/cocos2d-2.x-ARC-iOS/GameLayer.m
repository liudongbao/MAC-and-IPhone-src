//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Steffen Itterheim on 11.04.12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

@implementation GameLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer* layer = [GameLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    }
	
    return self;
}

-(void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

@end
