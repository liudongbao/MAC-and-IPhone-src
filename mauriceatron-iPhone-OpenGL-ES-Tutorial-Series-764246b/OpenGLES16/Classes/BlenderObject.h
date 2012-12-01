//
//  BlenderObject.h
//  OpenGLES16
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef struct __GLVertexElement {
	GLfloat coordiante[3];
	GLfloat normal[3];
	GLfloat texCoord[2];
} GLVertexElement;

@interface BlenderObject : NSObject {

    int vertexCount;
    unsigned short triangleCount;           // Equivalent to len(mesh.faces)
    GLVertexElement *data;
	GLuint texture;
	
}

- (NSError *)loadBlenderObject:(NSString *)fileName;
- (void)draw;
- (NSError *)loadTexture:(NSString *)fileName;

@end
