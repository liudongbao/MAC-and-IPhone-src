//
//  EAGLView.m
//  OpenGLES11
//
//  Created by Simon Maurice on 25/04/09.
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
		
		[self setupView];

		glGenTextures(10, &textures[0]);
		[self loadTexture:@"combinedtextures.png" intoLocation:textures[0]];
		[self loadTexture:@"bluetex.png" intoLocation:textures[1]];
		[self loadTexture:@"romo.png" intoLocation:textures[2]];
		
		// Render to Texture texture buffer setup
		glBindTexture(GL_TEXTURE_2D, textures[3]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 128, 128, 0, GL_RGBA, GL_UNSIGNED_BYTE, nil);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
    return self;
}


- (void)drawView {

#define WOOD_TC_OFFSET  0
#define BRICK_TC_OFFSET 8
#define FLOOR_TC_OFFSET 16
#define CEILING_TC_OFFSET 24
    
    const GLfloat combinedTextureCoordinate[] = {
        // The wood wall texture
        0.0, 1.0,       // Vertex[0~2] top left of square
        0.0, 0.5,       // Vertex[3~5] bottom left of square
        0.5, 0.5,       // Vertex[6~8] bottom right of square
        0.5, 1.0,       // Vertex[9~11] top right of square
        
        // The brick texture
        0.5, 1.0,
        0.5, 0.5,
        1.0, 0.5,
        1.0, 1.0,
        
        // Floor texture
        0.0, 0.5,
        0.0, 0.0,
        0.5, 0.0,
        0.5, 0.5,
        
        // Ceiling texture
        0.5, 0.5,
        0.5, 0.0,
        1.0, 0.0,
        1.0, 0.5
    };
    
    const GLfloat elementVerticies[] = {
        -1.0, 1.0, 0.0,     // Top left
        -1.0, -1.0, 0.0,    // Bottom left
        1.0, -1.0, 0.0,     // Bottom right
        1.0, 1.0, 0.0       // Top right
    };
    
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glMatrixMode(GL_MODELVIEW);

    glBindTexture(GL_TEXTURE_2D, textures[0]);
    glVertexPointer(3, GL_FLOAT, 0, elementVerticies);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    // Draw the Floor
    // First, point the texture co-ordinate engine at the right offset
    glTexCoordPointer(2, GL_FLOAT, 0, &combinedTextureCoordinate[FLOOR_TC_OFFSET]);
    for (int i = 0; i < 5; i++) {
        glPushMatrix();
        {
            glTranslatef(-1.0, -1.0, -2.0+(i*-2.0));
            glRotatef(-90.0, 1.0, 0.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
        
        glPushMatrix();
        {
            glTranslatef(1.0, -1.0, -2.0+(i*-2.0));
            glRotatef(-90.0, 1.0, 0.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
    }
    
    // Draw the walls
    // This time we'll change the texture coordinate array during the drawing
    for (int i = 0; i < 5; i++) {
        glPushMatrix();
        {
            glTexCoordPointer(2, GL_FLOAT, 0, &combinedTextureCoordinate[BRICK_TC_OFFSET]);
            glTranslatef(-1.0, 0.0, -2.0+(i*-2.0));
            glRotatef(-90.0, 0.0, 1.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
        
        glPushMatrix();
        {
            glTexCoordPointer(2, GL_FLOAT, 0, &combinedTextureCoordinate[WOOD_TC_OFFSET]);
            glTranslatef(1.0, 0.0, -2.0+(i*-2.0));
            glRotatef(-90.0, 0.0, 1.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
    }
    
    // Draw the ceiling
    // Start by setting the texture coordinate pointer
    glTexCoordPointer(2, GL_FLOAT, 0, &combinedTextureCoordinate[CEILING_TC_OFFSET]);
    for (int i = 0; i < 5; i++) {
        glPushMatrix();
        {
            glTranslatef(-1.0, 1.0, -2.0+(i*-2.0));
            glRotatef(90.0, 1.0, 0.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
        glPushMatrix();
        {
            glTranslatef(1.0, 1.0, -2.0+(i*-2.0));
            glRotatef(90.0, 1.0, 0.0, 0.0);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        glPopMatrix();
    }
	
	
	///////////////
	// Render to Texture section
	
    const GLfloat standardTextureCoordinates[] = {
        0.0, 1.0,
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0
    };
    // Draw the Blue texture & Blend #9 in front
    glTexCoordPointer(2, GL_FLOAT, 0, standardTextureCoordinates);
    glPushMatrix();
    {
		glBindTexture(GL_TEXTURE_2D, textures[1]);
        glTranslatef(0.0, 0.0, -6.0);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glBindTexture(GL_TEXTURE_2D, textures[2]);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTranslatef(0.0, 0.0, 0.1);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glDisable(GL_BLEND);

    }
    glPopMatrix();
	
	// Now do the render to texture operation
	// First copy the section of the display and then draw it back on
	glLoadIdentity();
	glBindTexture(GL_TEXTURE_2D, textures[3]);
	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 100, 150, 128, 128);
	glPushMatrix();
	{
		glTranslatef(0.0, -1.0, -2.0);
//		glRotatef(-75.0, 1.0, 0.0, 0.0);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
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
	
	GLfloat xmin, xmax, ymin, ymax;
	GLfloat aspect = (GLfloat) backingWidth / backingHeight;
	GLfloat zNear = 0.1f;
	GLfloat zFar = 100.0f;
	
	ymax = zNear * tan(45.0f * M_PI / 360.0);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
	
	glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
	
	
    /*const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
	GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
*/
	    CGRect rect = self.bounds;
	glViewport(0, 0, rect.size.width, rect.size.height);
	
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
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
	
	// Rotate the image
	CGContextTranslateCTM(textureContext, 0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0);

	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
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
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView)
														 userInfo:nil repeats:YES];
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


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
