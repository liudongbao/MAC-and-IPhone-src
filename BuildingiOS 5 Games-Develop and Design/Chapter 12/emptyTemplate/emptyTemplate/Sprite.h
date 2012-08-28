//
//  Sprite.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct
{
    GLfloat   m[4][4];
} ESMatrix;

@interface Sprite : NSObject<NSCopying> {
 
    GLuint name;
    BOOL dirtyBit;
    CGPoint position;
    UIImage *_image;
    
    GLuint VERT;
    GLuint texCoord;
    GLuint uniform;
    GLuint translation;
    GLuint program;
    GLfloat vertices[8];
    
}

@property (nonatomic, assign) GLuint name;
@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) int tag;

- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImage:(UIImage *)image;

- (void)initVertexInfo;
- (void)draw;
- (void)drawAtPosition:(CGPoint)aposition;

- (void)updateTransforms;
- (void)initEffect;

- (BOOL)hasCollidedBoundingBox:(CGRect)otherSprite;
- (BOOL)hasCollidedBoundingCircle:(CGRect)otherSprite;

void esTranslate(ESMatrix *result, GLfloat tx, GLfloat ty, GLfloat tz);
void esMatrixLoadIdentity(ESMatrix *result);

@end
