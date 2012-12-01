//
//  Projectile.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 4/27/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile
@synthesize monstersHit = _monstersHit;

- (Projectile*)initWithFile:(NSString *)file {
    if ((self = [super initWithFile:file])) {
        self.monstersHit = [NSMutableArray array];
    }
    return self;
}

- (BOOL)shouldDamageMonster:(CCSprite *)monster {
    if ([_monstersHit containsObject:monster]) {
        return FALSE;
    }
    else {
        [_monstersHit addObject:monster];
        return TRUE;
    }
}

- (void) dealloc
{
    self.monstersHit = nil;    
    [super dealloc];
}

@end
