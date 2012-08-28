//
//  Sprite.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface Sprite : NSObject<NSCopying> {
 
    GLuint name;
    BOOL dirtyBit;
    CGPoint position;
    UIImage *_image;
    GLKTextureInfo *textureInfo;
}

@property (nonatomic, assign) GLuint name;
@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;
@property (nonatomic, retain) GLKBaseEffect *effect;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) GLKMatrix4 transformation;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) GLKTextureInfo *textureInfo;

- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImage:(UIImage *)image;

- (void)initVertexInfo;
- (void)draw;
- (void)drawAtPosition:(CGPoint)aposition;

- (void)updateTransforms;
- (void)initEffect;

- (BOOL)hasCollidedBoundingBox:(CGRect)otherSprite;
- (BOOL)hasCollidedBoundingCircle:(CGRect)otherSprite;

@end
