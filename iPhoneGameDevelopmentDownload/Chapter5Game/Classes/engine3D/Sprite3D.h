//
//  Sprite3D.h
//  GLGravity
//
//  Created by Joe Hogue on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"
#import "PVRTVector.h"
#import "PVRTQuaternion.h"

@interface Sprite3D : NSObject {
	Model* model; //soft pointer to the model geometry
	PVRTVec3 translate;
	//float rotate[4]; //probably should be a quaternion, but gl wants angle/axis, so it's angle/axis [angle, x, y, z]
	PVRTQUATERNION rotate;
	float scale;
	float frame;
}

@property (nonatomic, retain) Model* model;
+ (Sprite3D*) spriteWithModel:(Model*)m;
- (void) draw;
- (void) updateFrame:(float) framedelta;

- (void) setTranslateX:(float)x Y:(float)y Z:(float)z;

//aligns this object's z axis to coincide with the given world axis.
- (void) forwardX:(float)x Y:(float)y Z:(float)z;

- (void) yaw:(float)yaw;
- (void) pitch:(float)pitch;

- (PVRTVec3) getAxis:(PVRTVec3)axis;

@property (nonatomic) float frame, scale;
@property (nonatomic, readonly) int numFrames;

@property (nonatomic) PVRTVec3 position;
@property (nonatomic) PVRTQUATERNION rotation;

@end
