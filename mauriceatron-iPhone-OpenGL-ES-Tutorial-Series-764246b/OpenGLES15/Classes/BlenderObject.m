//
//  BlenderObject.m
//  OpenGLES15
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import "BlenderObject.h"


@implementation BlenderObject

- (NSError *)loadBlenderObject:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"gldata"];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        NSString *msg = @"Something went really, really wrong...";
        return [NSError errorWithDomain:@"BlenderObject"
                                   code:0
                               userInfo:[NSDictionary dictionaryWithObject:msg
                                                                    forKey:NSLocalizedDescriptionKey]];
    }
    
	[[handle readDataOfLength:sizeof(int)] getBytes:&vertexCount];
	[[handle readDataOfLength:sizeof(unsigned short)] getBytes:&triangleCount];

	// For testing
//	NSLog(@"Vertex Count: %d", vertexCount);
//	NSLog(@"Triangle Count: %d", triangleCount);
	
	vertexArray = malloc(sizeof(GLfloat) * 6 * vertexCount);
	indexArray = malloc(sizeof(unsigned short) * triangleCount * 3);
	[[handle readDataOfLength:sizeof(GLfloat)*6*vertexCount] getBytes:vertexArray];
	[[handle readDataOfLength:sizeof(unsigned short) * triangleCount * 3] getBytes:indexArray];
	
	// For testing
	/*
	for (int i = 0; i < vertexCount * 6; i += 6) {
		NSLog(@"Vertex: %f  %f  %f", vertexArray[i], vertexArray[i+1], vertexArray[i+2]);
		NSLog(@"Normal: %f  %f  %f", vertexArray[i+3], vertexArray[i+4], vertexArray[i+5]);
	}
	for (int i = 0; i < triangleCount * 3; i += 3) {
		NSLog(@"Triangle Index: %d %d %d", indexArray[0], indexArray[i+1], indexArray[i+2]);
	}
	*/
	return nil;
}


- (void)draw {
	glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(GLfloat)*6, vertexArray);
	glNormalPointer(GL_FLOAT, sizeof(GLfloat)*6, &vertexArray[3]);
    glDrawElements(GL_TRIANGLES, triangleCount*3, GL_UNSIGNED_SHORT, indexArray);
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
}


@end
