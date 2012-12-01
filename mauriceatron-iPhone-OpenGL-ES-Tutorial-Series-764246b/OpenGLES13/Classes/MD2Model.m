//
//  MD2Model.m
//  OpenGLES14
//
//  Created by Simon Maurice on 5/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import "MD2Model.h"


@implementation MD2Model

- (id)init {
	if (self = [super init]) {
		currentFrame = 0;
	}
	return self;
}

- (NSError *)loadMD2Model:(NSString *)filename withSkinFilename:(NSString *)skinFileName {
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"md2"];
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
	
	[[handle readDataOfLength:sizeof(MD2Header)] getBytes:&header];
	
	// Ensure the header has the magic number
	if (header.ident != 844121161) {
		NSString *msg = [NSString stringWithFormat:@"Error: file has incorrect ident tag: %d", header.ident];
		return [NSError errorWithDomain:@"MD2Model"
								   code:0
							   userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
	}
	
	// Allocate some memory for our components
	skins = calloc(sizeof(MD2Skin), header.skinCount);
	texSTs = calloc(sizeof(MD2TextureST), header.stCount);
	triangles = calloc(sizeof(MD2Triangle), header.triangleCount);
	frames = calloc(sizeof(MD2Frame), header.frameCount);
	glCommands = calloc(sizeof(int), header.glCommandCount);
	
	// Read the skins
	[handle seekToFileOffset:header.skinOffset];
	[[handle readDataOfLength:sizeof(MD2Skin)*header.skinCount] getBytes:skins];
	// Read STs
	[handle seekToFileOffset:header.stOffset];
	[[handle readDataOfLength:sizeof(MD2TextureST)*header.stCount] getBytes:texSTs];
	// Triangles
	[handle seekToFileOffset:header.triangleOffset];
	[[handle readDataOfLength:sizeof(MD2Triangle)*header.triangleCount] getBytes:triangles];
	// GL Commands
	[handle seekToFileOffset:header.glCommandOffset];
	[[handle readDataOfLength:sizeof(int)*header.glCommandCount] getBytes:glCommands];
	
	// Read the frames
	
	[handle seekToFileOffset:header.frameOffset];
	
	for (int i = 0; i < header.frameCount; i++) {
		frames[i].vertices = (MD2Vertex *)calloc(sizeof(MD2Vertex), header.vertexCount);
		
		// Read frame data
		[[handle readDataOfLength:sizeof(MD2Vector)] getBytes:frames[i].scale];
		[[handle readDataOfLength:sizeof(MD2Vector)] getBytes:frames[i].translate];
		[[handle readDataOfLength:sizeof(char)*16] getBytes:frames[i].name];
		
		[[handle readDataOfLength:sizeof(MD2Vertex)*header.vertexCount] getBytes:frames[i].vertices];
	}
	
	[self loadTexture:skinFileName intoLocation:texture];
	
	NSLog(@"Frame Count: %d", header.frameCount);
	
	return nil;
}

- (void)draw:(NSInteger)frameNumber {
	
	currentFrame = frameNumber;
	
	glBindTexture(GL_TEXTURE_2D, texture);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	GLfloat triangleVertices[9];
	GLfloat triangleSTs[6];
	MD2Frame *f = &frames[frameNumber];
	for (int i = 0; i < header.triangleCount; i++) {
		for (int j = 0; j < 3; j++) {
			MD2Vertex *vertexPtr = &f->vertices[triangles[i].vertex[j]];
			
			// Calculate the uncompressed position
			triangleVertices[j*3] = f->scale[0] * vertexPtr->v[0] + f->translate[0];
			triangleVertices[j*3+1] = f->scale[1] * vertexPtr->v[1] + f->translate[1];
			triangleVertices[j*3+2] = f->scale[2] * vertexPtr->v[2] + f->translate[2];
			
			int mys = texSTs[triangles[i].st[j]].s;
			int myt = texSTs[triangles[i].st[j]].t;
			
			GLfloat das = (GLfloat)mys / header.skinWidth;
			GLfloat dat = (GLfloat)myt / header.skinHeight;
			triangleSTs[j*2] = das;
			triangleSTs[j*2+1] = dat;
			//triangleSTs[j*2] = texSTs[triangles[i].st[j]].s / header.skinWidth;
			//triangleSTs[j*2+1] = texSTs[triangles[i].st[j]].t / header.skinHeight;
			
			BOOL done = NO;
			if (done) {
				break;
			}
		}
		
		// Triangle assembled. Draw that bad boy
		glVertexPointer(3, GL_FLOAT, 0, triangleVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, triangleSTs);
		glDrawArrays(GL_TRIANGLES, 0, 3);
	}
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_VERTEX_ARRAY);
	glDisable(GL_TEXTURE_COORD_ARRAY);
}

- (void)drawNextFrame {
	currentFrame++;
	if (currentFrame == header.frameCount) {
		currentFrame = 0;
	}
	NSLog(@"Now Rendering Frame #%d: %s", currentFrame, frames[currentFrame].name);
	[self draw:currentFrame];
}

- (void)drawCurrentFrame {
	[self draw:currentFrame];
}

- (void)draw {
	
	GLfloat triangleVertices[2048*3];
	GLfloat triangleSTs[2048*3];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture);

	MD2Frame *f = &frames[0];
	MD2Vertex *vertex;
	int i;
	
	int *glCmdPtr = glCommands;
	MD2GLCommand *pkt;
	GLenum drawMode;
	
	while ((i = *(glCmdPtr++)) != 0) {
		if (i > 0) {
			drawMode = GL_TRIANGLE_STRIP;
		} else {
			drawMode = GL_TRIANGLE_FAN;
			i = -i;
		}
		
		// i is the number of vertices. So we need i * 3 for the vertex co-ordinates and i * 2 for the STs
//		triangleVertices = (GLfloat *) malloc(sizeof(GLfloat)*3*i);
//		triangleSTs = (GLfloat *)malloc(sizeof(GLfloat)*2*i);
		
		NSInteger vertexCount = i;
				
		for (int t = 0, t2 = 0; i > 0; --i, glCmdPtr += 3, t += 3, t2+=2) {
			pkt = (MD2GLCommand *)glCmdPtr;
			vertex = &frames[i].vertices[pkt->index];
			triangleVertices[t] = (f->scale[0] * vertex->v[0]) + f->translate[0];
			triangleVertices[t+1] = (f->scale[1] * vertex->v[1]) + f->translate[1];
			triangleVertices[t+2] = (f->scale[2] * vertex->v[2]) + f->translate[2];
			
			triangleSTs[t2] = pkt->s;
			triangleSTs[t2+1] = pkt->t;
			
		}

		glVertexPointer(3, GL_FLOAT, 0, triangleVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, triangleSTs);
		if (drawMode == GL_TRIANGLE_FAN)
			glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount*3);
		else
			glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount*3);

		if (glGetError() != GL_NO_ERROR) {
			NSLog(@"GL Error");
		}
//		free(triangleVertices);
//		free(triangleSTs);
	}
		
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)loadTexture:(NSString *)name intoLocation:(GLuint)location {
	
	CGImageRef textureImage = [UIImage imageNamed:name].CGImage;
	if (textureImage == nil) {
        NSLog(@"Failed to load texture image");
		return;
    }
	
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
//	CGContextTranslateCTM(textureContext, 0, texHeight);
//	CGContextScaleCTM(textureContext, 1.0, -1.0);
	
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}


- (void)dealloc {
	
	if (skins)
		free(skins);
	if (texSTs)
		free(texSTs);
	if (triangles)
		free(triangles);
	if (glCommands)
		free(glCommands);
	
	for (int i = 0; i < header.frameCount; i++) {
		free(frames[i].vertices);
	}
	free(frames);
	
	[super dealloc];
}


@end
