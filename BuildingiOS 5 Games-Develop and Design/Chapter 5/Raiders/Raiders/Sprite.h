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

@interface Sprite : NSObject {
 
    GLuint name;
    BOOL dirtyBit;
    CGPoint position;
    
    GLKTextureInfo *textureInfo;
    

}

@property (nonatomic, readonly) GLuint name;
@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;
@property (nonatomic, retain) GLKBaseEffect *effect;
@property (nonatomic, readonly) CGRect bounds;

@property (nonatomic, assign) GLKMatrix4 transformation;

- (id)initWithImageNamed:(NSString *)imageName;
- (void)initVertexInfo;
- (void)draw;
- (void)drawAtPosition:(CGPoint)aposition;

- (void)updateTransforms;
- (void)initEffect;

@end
