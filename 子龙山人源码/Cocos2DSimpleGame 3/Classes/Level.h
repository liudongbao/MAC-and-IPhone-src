//
//  Level.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 3/22/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject {
    int _levelNum;
    float _spawnRate;
    NSString *_bgImageName;
}

@property (nonatomic, assign) int levelNum;
@property (nonatomic, assign) float spawnRate;
@property (nonatomic, copy) NSString *bgImageName;

- (id)initWithLevelNum:(int)levelNum spawnRate:(float)spawnRate bgImageName:(NSString *)bgImageName;

@end
