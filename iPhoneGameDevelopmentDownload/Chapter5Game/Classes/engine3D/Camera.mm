//
//  Camera.m
//  Chapter5
//
//  Created by Joe Hogue on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"
#import "PVRTVector.h"
#import "PVRTMatrix.h"

@implementation Camera

//#define setquat(quat, _w, _x, _y, _z) {quat.x=(_x); quat.y=(_y); quat.z=(_z); quat.w=(_w); }

//This function computes a matrix and multiplies it with whatever is in *matrix.
//eyePosition3D is a XYZ position. This is where you are (your eye is).
//center3D is the XYZ position where you want to look at.
//upVector3D is a XYZ normalized vector. Quite often 0.0, 1.0, 0.0
//from http://www.opengl.org/wiki/GluLookAt_code
//before i looked in the pvrt docs for PVRTMatrixLookAtLHF, doh!
void glhLookAtf2(float *matrix, float *eyePosition3D, float *center3D, float *upVector3D)
{
    float forward[3], side[3], up[3];
    float matrix2[16], resultMatrix[16];
    //------------------
    forward[0] = center3D[0] - eyePosition3D[0];
    forward[1] = center3D[1] - eyePosition3D[1];
    forward[2] = center3D[2] - eyePosition3D[2];
    PVRTMatrixVec3Normalize(*((PVRTVec3*)forward), *((PVRTVec3*)forward));
    //------------------
    //Side = forward x up
    PVRTMatrixVec3CrossProduct(*((PVRTVec3*)side), *((PVRTVec3*)forward), *((PVRTVec3*)upVector3D));
    PVRTMatrixVec3Normalize(*((PVRTVec3*)side), *((PVRTVec3*)side));
    //------------------
    //Recompute up as: up = side x forward
    PVRTMatrixVec3CrossProduct(*((PVRTVec3*)up), *((PVRTVec3*)side), *((PVRTVec3*)forward));
    //------------------
    matrix2[0] = side[0];
    matrix2[4] = side[1];
    matrix2[8] = side[2];
    matrix2[12] = 0.0;
    //------------------
    matrix2[1] = up[0];
    matrix2[5] = up[1];
    matrix2[9] = up[2];
    matrix2[13] = 0.0;
    //------------------
    matrix2[2] = -forward[0];
    matrix2[6] = -forward[1];
    matrix2[10] = -forward[2];
    matrix2[14] = 0.0;
    //------------------
    matrix2[3] = matrix2[7] = matrix2[11] = 0.0;
    matrix2[15] = 1.0;
    //------------------
    PVRTMatrixMultiply(*((PVRTMat4*)resultMatrix), *((PVRTMat4*)matrix), *((PVRTMat4*)matrix2));
    //PVRTMatrixTranslation(*((PVRTMat4*)resultMatrix), -eyePosition3D[0], -eyePosition3D[1], -eyePosition3D[2]); //we're doing this separately.
    //------------------
    memcpy(matrix, resultMatrix, 16*sizeof(float));
}


-(void) dealloc {
	[super dealloc];
}

+ (Camera*) camera {
	Camera* retval = [[Camera alloc] init];
	retval->rotate.w = 1;
	return [retval autorelease];
}

- (void) apply {

	PVRTMat4 view; //todo: cache this?
	PVRTMatrixRotationQuaternion(view, rotate);
	PVRTMatrixInverse(view, view);
	
	glTranslatef(-boom.x, -boom.y, -boom.z);
	glMultMatrixf((float*)&view);
	glTranslatef(-translate.x, -translate.y, -translate.z);
}

- (void) offsetLook:(float)look up:(float)up right:(float)right {
	boom.z = look;
	boom.y = up;
	boom.x = right;
}

@end
