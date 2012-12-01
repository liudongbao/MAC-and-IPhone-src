//
//  MD2Model.h
//  OpenGLES14
//
//  Created by Simon Maurice on 5/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

// Structure for containing the file header from the MD2 file
typedef struct __MD2Header {
	int ident;
	int version;
	
	int skinWidth;
	int skinHeight;
	
	int frameSize;
	
	int skinCount;
	int vertexCount;
	int stCount;
	int triangleCount;
	int glCommandCount;
	int frameCount;
	
	int skinOffset;
	int stOffset;
	int triangleOffset;
	int frameOffset;
	int glCommandOffset;
	int eofOffset;
} MD2Header;

typedef float MD2Vector[3];

typedef struct __MD2TextureST {
	short s;
	short t;
} MD2TextureST;

typedef struct __MD2Triangle {
	unsigned short vertex[3];
	unsigned short st[3];
} MD2Triangle;

typedef struct __MD2Vertex {
	unsigned char v[3];				
	unsigned char normalIndex;
} MD2Vertex;

typedef struct __MD2Frame {
	MD2Vector scale;
	MD2Vector translate;
	char name[16];
	MD2Vertex *vertices;
} MD2Frame;

typedef struct __MD2Skin {
	char name[64];
} MD2Skin;

typedef struct __MD2GLCommand {
	float s;
	float t;
	int index;
} MD2GLCommand;

@interface MD2Model : NSObject {
	
	MD2Header header;
	
	MD2Skin *skins;
	MD2TextureST *texSTs;
	MD2Triangle *triangles;
	MD2Frame *frames;
	int *glCommands;
	
	GLuint texture;
	
	NSInteger currentFrame;
	NSInteger nextFrame;
	NSInteger animStartFrame;
	NSInteger animEndFrame;
	float animInterpolation;
	float currentInterpolation;
}

- (NSError *)loadMD2Model:(NSString *)filename withSkinFilename:(NSString *)skinFileName;
- (void)loadTexture:(NSString *)name intoLocation:(GLuint)location;

- (void)draw;
- (void)draw:(NSInteger)frameNumber;
- (void)drawNextFrame;
- (void)drawCurrentFrame;

- (void)animateFromFrame:(NSInteger)startFrame toFrame:(NSInteger)endFrame withInterpolation:(float)interpolation;
- (void)drawAnimated;

- (NSInteger)frameCount;
- (NSArray *)frameNames;

@end
