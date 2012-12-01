//
//  BBAnimation.h
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneObject.h"


@interface BBAnimation : BBSceneObject {

}

- (id) initWithAtlasKeys:(NSArray*)keys loops:(BOOL)loops speed:(NSInteger)speed;
- (void)awake;
- (void)update;

// 3 methods


@end
