//
//  BBMobileObject.h
//  SpaceRocks
//
//  Created by ben smith on 3/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneObject.h"

@interface BBMobileObject : BBSceneObject {
	BBPoint speed;
	BBPoint rotationalSpeed;
}

@property (assign) BBPoint speed;
@property (assign) BBPoint rotationalSpeed;

- (void)checkArenaBounds;
- (void)update;

// 2 methods


@end
