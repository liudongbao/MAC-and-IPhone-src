//
//  BlenderObject.h
//  OpenGLES15
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface BlenderObject : NSObject {

    int vertexCount;
    unsigned short triangleCount;           // Equivalent to len(mesh.faces)
    GLfloat *vertexArray;
    unsigned short *indexArray;
	
}

- (NSError *)loadBlenderObject:(NSString *)fileName;
- (void)draw;

@end
