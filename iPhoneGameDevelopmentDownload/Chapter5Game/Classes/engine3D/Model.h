//
//  Model.h
//  GLGravity
//
//  Created by Joe Hogue on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>

//class CPVRTModelPOD;

@interface Model : NSObject {
	void* model; //this is a CPVRTModelPOD, but we're faking it to void to hide the c++ implementation in the pvrt codebase.
	GLuint *vbo, *indexvbo, *texture; //these have to be dynamic, because the loaded model can have any number of submeshes or textures.
}

+ (Model*) modelFromFile:(NSString*) filename;
- (void) load:(NSString*)filename;
- (void) draw;
- (void) setFrame:(float) frame;

@property (nonatomic, readonly) int numFrames;

@end
