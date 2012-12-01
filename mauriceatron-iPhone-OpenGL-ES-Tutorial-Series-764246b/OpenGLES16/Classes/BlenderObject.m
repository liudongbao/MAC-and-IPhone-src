//
//  BlenderObject.m
//  OpenGLES16
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
	
	data = malloc(sizeof(GLVertexElement) * triangleCount * 3);
	[[handle readDataOfLength:sizeof(GLVertexElement) * triangleCount * 3] getBytes:data];

	NSError *error = [self loadTexture:fileName];
	if (error) {
		NSLog(@"Error loading texture");
	}
	
	return nil;
}


- (void)draw {
	glBindTexture(GL_TEXTURE_2D, texture);
	glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glVertexPointer(3, GL_FLOAT, sizeof(GLVertexElement), data);
	glNormalPointer(GL_FLOAT, sizeof(GLVertexElement), data->normal);
	glTexCoordPointer(2, GL_FLOAT, sizeof(GLVertexElement), data->texCoord);
	glDrawArrays(GL_TRIANGLES, 0, triangleCount*3);
	
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

- (NSError *)loadTexture:(NSString *)fileName {
	
	NSString *name = [NSString stringWithFormat:@"%@.%@", fileName, @"png"];
	CGImageRef textureImage = [UIImage imageNamed:name].CGImage;
	if (textureImage == nil) {
		return [NSError errorWithDomain:nil
								   code:0
							   userInfo:[NSDictionary dictionaryWithObject:@"Error loading file"
																	forKey:NSLocalizedDescriptionKey]];
	}
	
	NSInteger texWidth = CGImageGetWidth(textureImage);
	NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
	CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextTranslateCTM(textureContext, 0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	return nil;
}

- (void)dealloc {
	if (data != nil) {
		free(data);
	}
	glDeleteTextures(1, &texture);			// No need to check if texture is in use.
	[super dealloc];
}

@end
