//
//  Sprite.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "Sprite.h"

@implementation Sprite

static const GLfloat vertices[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
    
};

static const GLfloat texCoords[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

static const GLushort cubeIndices[] =
{
    0, 2, 1,
    1, 2, 3, 
};

@synthesize name;
@synthesize width, height;
@synthesize transformation;
@synthesize effect;
@synthesize bounds;

@synthesize tag;

- (id)initWithImageNamed:(NSString *)imageName {
    self = [super init];
	if (self != nil) {
        textureInfo = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:imageName].CGImage options:nil error:nil];
        name = textureInfo.name;
        self.width = textureInfo.width;
        self.height = textureInfo.height;
        bounds = CGRectMake(0, 0, self.width, self.height);
        [self initVertexInfo];
        [self initEffect];
        [self updateTransforms];
        dirtyBit = NO;
    }
	return self;
}

- (void)initVertexInfo {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, 0, 0, texCoords);
    glBindVertexArrayOES(0);
}

- (void)initEffect {
    effect = [[GLKBaseEffect alloc] init];
    //effect.texturingEnabled = GL_TRUE;
    effect.texture2d0.name = name;
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.target = GLKTextureTarget2D;
    effect.light0.enabled = GL_FALSE;
}

- (void)updateTransforms { 
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0.0f, 320, 0.0f, 480, 0.0f, 1.0f);
    effect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeScale(self.width, self.height, -1.0f);
    modelViewMatrix = GLKMatrix4Multiply(transformation, modelViewMatrix);
    effect.transform.modelviewMatrix = modelViewMatrix;
}

- (void)drawAtPosition:(CGPoint)aposition {
    dirtyBit = YES;
    position = aposition;
    bounds = CGRectMake(position.x, position.y, self.width, self.height);
    [self draw];
}

- (void)draw {

    if (dirtyBit) {
        transformation = GLKMatrix4MakeTranslation(position.x, 480.0 - position.y - self.height, 0.0f);
    }
    
    [effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, cubeIndices);
    
    dirtyBit = NO;
}

@end
