//
//  Level.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 3/22/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Level.h"

@implementation Level

@synthesize spawnRate = _spawnRate;
@synthesize levelNum = _levelNum;
@synthesize bgImageName = _bgImageName;

- (id)initWithLevelNum:(int)levelNum spawnRate:(float)spawnRate bgImageName:(NSString *)bgImageName {
 
    if ((self = [super init])) {
        self.levelNum = levelNum;
        self.spawnRate = spawnRate;
        self.bgImageName = bgImageName;
    }
    
    return self;
    
}

@end
