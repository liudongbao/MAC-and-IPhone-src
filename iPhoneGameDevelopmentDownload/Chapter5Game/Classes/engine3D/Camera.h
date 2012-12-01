//
//  Camera.h
//  Chapter5
//
//  Created by Joe Hogue on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sprite3D.h"
#import "PVRTVector.h"
#import "PVRTQuaternion.h"

@interface Camera : Sprite3D {
	PVRTVec3 boom; //the follow distance from our view target.  used for rotating about the target while keeping it in view
}

+ (Camera*) camera;
- (void) apply;
- (void) offsetLook:(float)look up:(float)up right:(float)right;

@end
