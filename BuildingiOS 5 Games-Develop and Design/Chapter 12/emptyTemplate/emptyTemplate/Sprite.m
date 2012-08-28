//
//  Sprite.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Sprite.h"

@interface Sprite (private) 

- (void)getTextureInfo:(CGImageRef)imageRef;
- (void)initProperties;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation Sprite


static const GLfloat texCoords[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};

static const GLubyte cubeIndices[] =
{
    0, 2, 1,
    3, 0, 1,
};

@synthesize name;
@synthesize width, height;
@synthesize bounds;
@synthesize tag;

void esMatrixLoadIdentity(ESMatrix *result)
{
    memset(result, 0x0, sizeof(ESMatrix));
    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}

void esTranslate(ESMatrix *result, GLfloat tx, GLfloat ty, GLfloat tz)
{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}

#pragma mrk - init code

- (id)init {
    self = [super init];
	if (self != nil) {
        [self initProperties];
    }
	return self;
}

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
    copy.tag = self.tag;
    return copy;
}

-(void)getTextureInfo:(CGImageRef)imageRef {
    size_t wid  = CGImageGetWidth(imageRef);
    size_t hgt = CGImageGetHeight(imageRef);
    
    self.width = wid;
    self.height = hgt;
    
    GLubyte *textureData = (GLubyte *)calloc(wid * hgt * 4, sizeof(GLubyte));
    CGContextRef textureContext = CGBitmapContextCreate(textureData, wid, hgt, 8, wid * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(textureContext, CGRectMake(0, 0, wid, hgt), imageRef);
    CGContextRelease(textureContext);
    
    glGenTextures(1, &name);
    glBindTexture(GL_TEXTURE_2D, name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, wid, hgt, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    free(textureData);
    
}

- (void)initProperties {
    bounds = CGRectMake(0, 0, self.width, self.height);
    [self initVertexInfo];
    [self initEffect];
    [self updateTransforms];
    dirtyBit = NO;
}

- (void)initVertexInfo {
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [self loadShaders];
}

- (void)initEffect {
    vertices[0] = 0;  vertices[1] = 0; 
    vertices[2] = self.width; vertices[3] = 0;
    vertices[4] = 0;  vertices[5] = self.height;
    vertices[6] = self.width; vertices[7] = self.height;

}

#pragma mark -rendering code

- (void)updateTransforms { 

}

- (void)drawAtPosition:(CGPoint)aposition {
    dirtyBit = YES;
    position = aposition;
    bounds = CGRectMake(position.x, position.y, self.width, self.height);
    [self draw];
}

- (void)draw {
    ESMatrix matrix;
    esMatrixLoadIdentity(&matrix);
    
    if (dirtyBit) {
        esTranslate(&matrix, position.x, 480.0 - position.y - self.height, 0);
        glUniformMatrix4fv(translation, 1, GL_FALSE, &matrix.m[0][0]);
    }
    
    glEnableVertexAttribArray(VERT);
    glVertexAttribPointer(VERT, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, 0, texCoords);    
    
    glActiveTexture(GL_TEXTURE0); 
    glBindTexture(GL_TEXTURE_2D, name);
    glUniform1i(uniform, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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

#pragma mark - Shader Code

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    glUseProgram(program);
    
    texCoord = glGetAttribLocation(program, "texCoordIn");
    glEnableVertexAttribArray(texCoord);
    uniform = glGetUniformLocation(program, "Texture");
    translation = glGetUniformLocation(program, "translation");
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, 0, "position");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

@end
