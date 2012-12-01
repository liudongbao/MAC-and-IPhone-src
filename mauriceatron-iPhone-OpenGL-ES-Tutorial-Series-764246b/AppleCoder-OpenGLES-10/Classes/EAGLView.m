//
//  EAGLView.m
//  AppleCoder-OpenGLES-00
//
//  Created by Simon Maurice on 18/03/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,
										kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		glGenTextures(6, &textures[0]);
		
		rota = 0.0;

        [self setupView];
        glGenTextures(6, &textures[0]);
        [self loadTexture:@"bamboo.png" intoLocation:textures[0]];
        [self loadTexture:@"flowers.png" intoLocation:textures[1]];
        [self loadTexture:@"grass.png" intoLocation:textures[2]];
        [self loadTexture:@"lino.png" intoLocation:textures[3]];
        [self loadTexture:@"metal.png" intoLocation:textures[4]];
        [self loadTexture:@"schematic.png" intoLocation:textures[5]];
    }
    return self;
}


- (void)drawView {
        
    const GLfloat cubeVertices[] = {
        
        // Define the front face
        -1.0, 1.0, 1.0,             // top left
        -1.0, -1.0, 1.0,            // bottom left
        1.0, -1.0, 1.0,             // bottom right
        1.0, 1.0, 1.0,              // top right
        
        // Top face
        -1.0, 1.0, -1.0,            // top left (at rear)
        -1.0, 1.0, 1.0,             // bottom left (at front)
        1.0, 1.0, 1.0,              // bottom right (at front)
        1.0, 1.0, -1.0,             // top right (at rear)
        
        // Rear face
        1.0, 1.0, -1.0,             // top right (when viewed from front)
        1.0, -1.0, -1.0,            // bottom right
        -1.0, -1.0, -1.0,           // bottom left
        -1.0, 1.0, -1.0,            // top left
        
        // bottom face
        -1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0,
        1.0, -1.0, -1.0,
        1.0, -1.0, 1.0,
        
        // left face
        -1.0, 1.0, -1.0,
        -1.0, 1.0, 1.0,
        -1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0,
        
        // right face
        1.0, 1.0, 1.0,
        1.0, 1.0, -1.0,
        1.0, -1.0, -1.0,
        1.0, -1.0, 1.0
    };
    
    const GLshort squareTextureCoords[] = {
        // Front face
        0, 2,       // top left
        0, 0,       // bottom left
        2, 0,       // bottom right
        2, 2,       // top right
        
        // Top face
        0, 1,       // top left
        0, 0,       // bottom left
        1, 0,       // bottom right
        1, 1,       // top right
        
        // Rear face
        0, 1,       // top left
        0, 0,       // bottom left
        1, 0,       // bottom right
        1, 1,       // top right
        
        // Bottom face
        0, 1,       // top left
        0, 0,       // bottom left
        1, 0,       // bottom right
        1, 1,       // top right
        
        // Left face
        0, 1,       // top left
        0, 0,       // bottom left
        1, 0,       // bottom right
        1, 1,       // top right
        
        // Right face
        0, 1,       // top left
        0, 0,       // bottom left
        1, 0,       // bottom right
        1, 1,       // top right
    };
	
    [EAGLContext setCurrentContext:context];    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
    glMatrixMode(GL_MODELVIEW);
    
    glTexCoordPointer(2, GL_SHORT, 0, squareTextureCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // Our new drawing code goes here
    rota += 0.5;
	
    glPushMatrix();
    {
        glTranslatef(0.0, 0.0, -4.0);
        glRotatef(rota, 1.0, 1.0, 1.0);
        glRotatef(rota/2, 0.0, 0.0, 1.0);
        glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        // Draw the front face
        glBindTexture(GL_TEXTURE_2D, textures[0]);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        
        // Draw the top face
		glBindTexture(GL_TEXTURE_2D, textures[1]);
        glDrawArrays(GL_TRIANGLE_FAN, 4, 4);
		
		// Draw the rear face
		glBindTexture(GL_TEXTURE_2D, textures[2]);
        glDrawArrays(GL_TRIANGLE_FAN, 8, 4);
        
        // Draw the bottom face
		glBindTexture(GL_TEXTURE_2D, textures[3]);
        glDrawArrays(GL_TRIANGLE_FAN, 12, 4);
        
        // Draw the left face
		glBindTexture(GL_TEXTURE_2D, textures[4]);
        glDrawArrays(GL_TRIANGLE_FAN, 16, 4);
        
        // Draw the right face
		glBindTexture(GL_TEXTURE_2D, textures[5]);
        glDrawArrays(GL_TRIANGLE_FAN, 20, 4);
    }
    glPopMatrix();
    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    [self checkGLError:NO];
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)setupView {
	
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
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
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)checkGLError:(BOOL)visibleCheck {
    GLenum error = glGetError();
    
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
