//
//  EAGLView.m
//  OpenGLES13
//
//  Created by Simon Maurice on 22/05/09.
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

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz);


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
		
		position[0] = 0.0;
		position[1] = 0.0;
		position[2] = -50.0;
		
		facing[0] = facing[2] = 0.0;
		facing[1] = 0.0;
		
		currentMovement = MTNone;
		
		[self setupView];
		glGenTextures(10, &textures[0]);
		[self loadTexture:@"floor.png" intoLocation:textures[0]];
		
		m = [[MD2Model alloc] init];
		NSError *e = [m loadMD2Model:@"Weapon" withSkinFilename:@"weapon.png"];
		if (e) {
			NSLog(@"Error: %@", [e localizedDescription]);
		}
		
		doomGuy = [[MD2Model alloc] init];
		[doomGuy loadMD2Model:@"Trooper" withSkinFilename:@"Trooper.png"];
		
		isDrawing = NO;
		
		frameCounter = 30;
    }
    return self;
}


- (void)drawView {
	
	if (isDrawing)  {
		NSLog(@"We're drawing...");
		return;
	}
	isDrawing = YES;
	
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	glMatrixMode(GL_MODELVIEW);
/*
	const GLfloat floorVertices[] = {
        -1.0, 1.0, 0.0,     // Top left
        -1.0, -1.0, 0.0,    // Bottom left
        1.0, -1.0, 0.0,     // Bottom right
        1.0, 1.0, 0.0       // Top right
    };
	const GLfloat floorTC[] = {
		0.0, 1.0,
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0
	};
*/	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	/*
	glVertexPointer(3, GL_FLOAT, 0, floorVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, floorTC);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, textures[0]);
	glEnable(GL_TEXTURE_2D);
	*/
	glLoadIdentity();
	
	[self handleTouches];
	
	gluLookAt(position[0], position[1], position[2], facing[0], facing[1], facing[2], 0.0, 1.0, 0.0);

/*	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 10; j++) {
			
			glPushMatrix();
			{
				glTranslatef(10.0+(j*-2.0), -2.0, -2.0+(i*-2.0));
				glRotatef(-90.0, 1.0, 0.0, 0.0);
				glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
			}
			glPopMatrix();
		}
	}
	
	glDisable(GL_TEXTURE_2D);
*/	/*
	glPushMatrix();
	glTranslatef(-10.0, 5.0, -50);
	[m draw:0];
	glPopMatrix();
	*/
	glPushMatrix();
	glTranslatef(0.0, -35, 0.0);
	glRotatef(-90, 1, 0, 0);
	glRotatef(90, 0.0, 0.0, 1.0);
	//glRotatef(45, 0, 0, 0);
	if (frameCounter == 0) {
		[doomGuy drawNextFrame];
		frameCounter = 30;
	} else {
		[doomGuy drawCurrentFrame];
		frameCounter--;
	}
	glPopMatrix();
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	isDrawing = 0;
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
	
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
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
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil
														  repeats:YES];
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

#pragma mark Touch Handling

- (void)handleTouches {
    
    if (currentMovement == MTNone) {
        // We're going nowhere, nothing to do here
        return;
    }
    
    GLfloat vector[3];
    vector[0] = facing[0] - position[0];
    vector[1] = facing[1] - position[1];
    vector[2] = facing[2] - position[2];
    
    switch (currentMovement) {
        case MTWalkForward:
            facing[1] = position[1] + cos(-TURN_SPEED)*vector[1] - sin(-TURN_SPEED)*vector[2];
            facing[2] = position[2] + sin(-TURN_SPEED)*vector[1] + cos(-TURN_SPEED)*vector[2];
			break;
			
			/*
            position[0] += vector[0] * WALK_SPEED;
            position[2] += vector[2] * WALK_SPEED;
            facing[0] += vector[0] * WALK_SPEED;
            facing[2] += vector[2] * WALK_SPEED;
            break;
			*/
        case MTWAlkBackward:
            position[0] -= vector[0] * WALK_SPEED;
            position[2] -= vector[2] * WALK_SPEED;
            facing[0] -= vector[0] * WALK_SPEED;
            facing[2] -= vector[2] * WALK_SPEED;
            break;
			
        case MTTurnLeft:
            facing[0] = position[0] + cos(-TURN_SPEED)*vector[0] - sin(-TURN_SPEED)*vector[2];
            facing[2] = position[2] + sin(-TURN_SPEED)*vector[0] + cos(-TURN_SPEED)*vector[2];
            break;
			
        case MTTurnRight:
            facing[0] = position[0] + cos(TURN_SPEED)*vector[0] - sin(TURN_SPEED)*vector[2];
            facing[2] = position[2] + sin(TURN_SPEED)*vector[0] + cos(TURN_SPEED)*vector[2];
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *t = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPos = [t locationInView:t.view];
    
    // Detirmine the location on the screen. We are interested in iPhone Screen co-ordinates only, not the world co-ordinates
    //  because we are just trying to handle movement.
    //
    // (0, 0)
    //  +-----------+
    //  |           |
    //  |    160    |
    //  |-----------| 160
    //  |     |     |
    //  |     |     |
    //  |-----------| 320
    //  |           |
    //  |           |
    //  +-----------+ (320, 480)
    //
    
    if (touchPos.y < 160) {
        // We are moving forward
        currentMovement = MTWalkForward;
        
    } else if (touchPos.y > 320) {
        // We are moving backward
        currentMovement = MTWAlkBackward;
        
    } else if (touchPos.x < 160) {
        // Turn left
        currentMovement = MTTurnLeft;
    } else {
        // Turn Right
        currentMovement = MTTurnRight;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    currentMovement = MTNone;
}


#pragma mark SGI Copyright Functions

/*
 * SGI FREE SOFTWARE LICENSE B (Version 2.0, Sept. 18, 2008)
 * Copyright (C) 1991-2000 Silicon Graphics, Inc. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice including the dates of first publication and
 * either this permission notice or a reference to
 * http://oss.sgi.com/projects/FreeB/
 * shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * SILICON GRAPHICS, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of Silicon Graphics, Inc.
 * shall not be used in advertising or otherwise to promote the sale, use or
 * other dealings in this Software without prior written authorization from
 * Silicon Graphics, Inc.
 */

static void normalize(float v[3])
{
    float r;
	
    r = sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
    if (r == 0.0) return;
	
    v[0] /= r;
    v[1] /= r;
    v[2] /= r;
}

static void __gluMakeIdentityf(GLfloat m[16])
{
    m[0+4*0] = 1; m[0+4*1] = 0; m[0+4*2] = 0; m[0+4*3] = 0;
    m[1+4*0] = 0; m[1+4*1] = 1; m[1+4*2] = 0; m[1+4*3] = 0;
    m[2+4*0] = 0; m[2+4*1] = 0; m[2+4*2] = 1; m[2+4*3] = 0;
    m[3+4*0] = 0; m[3+4*1] = 0; m[3+4*2] = 0; m[3+4*3] = 1;
}

static void cross(float v1[3], float v2[3], float result[3])
{
    result[0] = v1[1]*v2[2] - v1[2]*v2[1];
    result[1] = v1[2]*v2[0] - v1[0]*v2[2];
    result[2] = v1[0]*v2[1] - v1[1]*v2[0];
}

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
		  GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
		  GLfloat upz)
{
    float forward[3], side[3], up[3];
    GLfloat m[4][4];
	
    forward[0] = centerx - eyex;
    forward[1] = centery - eyey;
    forward[2] = centerz - eyez;
	
    up[0] = upx;
    up[1] = upy;
    up[2] = upz;
	
    normalize(forward);
	
    /* Side = forward x up */
    cross(forward, up, side);
    normalize(side);
	
    /* Recompute up as: up = side x forward */
    cross(side, forward, up);
	
    __gluMakeIdentityf(&m[0][0]);
    m[0][0] = side[0];
    m[1][0] = side[1];
    m[2][0] = side[2];
	
    m[0][1] = up[0];
    m[1][1] = up[1];
    m[2][1] = up[2];
	
    m[0][2] = -forward[0];
    m[1][2] = -forward[1];
    m[2][2] = -forward[2];
	
    glMultMatrixf(&m[0][0]);
    glTranslatef(-eyex, -eyey, -eyez);
}

@end
