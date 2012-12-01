//
//  Ring.h
//  Chapter5
//
//  Created by Joe Hogue on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sprite3D.h"

@interface Ring : Sprite3D {
	int lastDistance; //part of collision detection.  we want to determine when the player crosses the plane of the ring, so we have to store the last known distance to deterimine crossing.  but we only care about direction, so this will store -1 or 1 only.
	PVRTVec3 normal; //we need to store the orientation of the ring (separate from rotate) so we can determine our collision plane
	bool active; //reset after player has flown through ring
}

+ (id) ringWithModel:(Model*)model;
- (bool) update:(float)time collideWith:(Sprite3D*) ship;

@property (nonatomic, readonly) PVRTVec3 normal;
@property (nonatomic, readonly) bool active;

@end
