//
//  Sprite3D.m
//  GLGravity
//
//  Created by Joe Hogue on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sprite3D.h"
#import "PVRTVector.h"

@implementation Sprite3D

@synthesize model;

@synthesize frame = frame;
@synthesize scale = scale;

@synthesize position = translate;
@synthesize rotation = rotate;

- (void) setTranslateX:(float)x Y:(float)y Z:(float)z {
	translate.x = x;
	translate.y = y;
	translate.z = z;
}


- (void) forwardX:(float)x Y:(float)y Z:(float)z {
	/*/
	rotate.w = 0; //yeah, no.  that looks off. --needed normalize, still slanty
	rotate.x = x;
	rotate.y = y;
	rotate.z = z;
	PVRTMatrixQuaternionNormalize(rotate);
	/*/
	PVRTVec3 up(x, y, z);
	up.normalize();
	PVRTVec3 axis = PVRTVec3(0,1,0).cross(up);
	axis.normalize();
	float dot = PVRTVec3(0,1,0).dot(up);
	float angle = acos(dot);// * 180 / PVRT_PI;
	PVRTMatrixQuaternionRotationAxis(rotate, -axis, angle); 
	//*/
}

- (id) init {
	[super init];
	[self setTranslateX:0 Y:0 Z:0];
	[self setScale:1.0f];
	
	PVRTMatrixQuaternionIdentity(rotate);
	
	return self;
}

+ (Sprite3D*) spriteWithModel:(Model*)m {
	Sprite3D* retval = [[Sprite3D alloc] init];
	retval.model = m;
	return [retval autorelease];
}

//assumptions: framedelta must be positive, and should be less than model.numFrames
- (void) updateFrame:(float) framedelta {
	frame += framedelta;
	if(frame >= model.numFrames){
		frame -= model.numFrames;
	}
}

- (void) draw {
	glPushMatrix();
	glTranslatef(translate.x, translate.y, translate.z);
	PVRTMat4 view; //todo: cache this?
	PVRTMatrixRotationQuaternion(view, rotate);
	//PVRTMatrixInverse(view, view);
	glMultMatrixf((float*)&view);
	glScalef(scale, scale, scale);
	if(model.numFrames > 1){
		[model setFrame:frame];
	}
	[model draw];
	glPopMatrix();
}

- (void) dealloc {
	self.model = nil;
	[super dealloc];
}

- (int) numFrames {
	return model.numFrames;
}


- (void) rotate:(float)angle axis:(PVRTVec3)axis {
	PVRTQUATERNION qtmp;
	PVRTMatrixQuaternionRotationAxis(qtmp, axis, -angle); //negating angle here is a hack, not sure what it correlates to.
	PVRTMatrixQuaternionMultiply(rotate, qtmp, rotate);
	PVRTMatrixQuaternionNormalize(rotate);
}

- (void) yaw:(float)yaw{
	[self rotate:yaw axis:PVRTVec3(0, 1, 0)];
}

- (void) pitch:(float)pitch{
	[self rotate:pitch axis:PVRTVec3(1, 0, 0)];
}

- (PVRTVec3) getAxis:(PVRTVec3)axis {
	PVRTMat4 view;
	PVRTMatrixRotationQuaternion(view, rotate);
	PVRTMatrixInverse(view, view);
	return axis*view;
}

@end
