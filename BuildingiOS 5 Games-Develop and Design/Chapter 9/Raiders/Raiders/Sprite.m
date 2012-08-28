//
//  Sprite.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "Sprite.h"

@interface Sprite (private)

- (void)getTextureInfo:(CGImageRef)imageRef;
- (void)initProperties;

@end

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
@synthesize textureInfo;
@synthesize tag;

#pragma mrk - init code

- (id)initWithImageNamed:(NSString *)imageName {
    self = [super init];
	if (self != nil) {
        [self getTextureInfo:[UIImage imageNamed:imageName].CGImage];
        [self initProperties];
    }
	return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
	if (self != nil) {
        _image = image;
        [self getTextureInfo:image.CGImage];
        [self initProperties];
    }
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Sprite *copy = [[[self class] alloc] initWithImage:_image];
    //copy.textureInfo = self.textureInfo;
    //copy.name = self.name;
    //copy.width = self.width;
    //copy.height = self.height;
    //copy.effect = self.effect;
    //copy.bounds = self.bounds;
    copy.tag = self.tag;
    return copy;
}

-(void)getTextureInfo:(CGImageRef)imageRef {
    NSError *error;
    textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:&error];
}

- (void)initProperties {
    name = textureInfo.name;
    self.width = textureInfo.width;
    self.height = textureInfo.height;
    bounds = CGRectMake(0, 0, self.width, self.height);
    [self initVertexInfo];
    [self initEffect];
    [self updateTransforms];
    dirtyBit = NO;
}

- (void)initVertexInfo {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
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

#pragma mark -rendering code

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

#pragma mark - Collision Code

- (BOOL)hasCollidedBoundingBox:(CGRect)otherSprite {
    return CGRectIntersectsRect(self.bounds, otherSprite);
}

- (BOOL)hasCollidedBoundingCircle:(CGRect)otherSprite {
    //choose height as sprites are largely rectangular in shape
    float radius1 = self.height;
    float radius2 = otherSprite.size.height;
    CGPoint center1 = CGPointMake(self.width / 2 + self.bounds.origin.x, self.height / 2 + self.bounds.origin.y);
    CGPoint center2 = CGPointMake(otherSprite.size.width / 2 + otherSprite.origin.x , otherSprite.size.height + otherSprite.origin.y);
    
    float distX = center1.x - center2.x;
    float distY = center1.y - center2.y;
    
    float distance = sqrtf((distX * distX) + (distY * distY));
    
    return distance <= radius1 + radius2;
}

@end
