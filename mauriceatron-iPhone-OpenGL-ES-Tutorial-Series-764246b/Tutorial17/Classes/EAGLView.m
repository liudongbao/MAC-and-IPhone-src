//
//  EAGLView.m
//  Tutorial17
//
//  Created by Simon Maurice on 25/07/09.
//  Copyright Simon Maurice 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)


// Function prototypes for the collision detection
void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz);
float locationToPlane(float triangle[9], float fromPos[3]);
void triangleNormal(float triangle[9], float normal[3]);
void intersectWithPlane(float *fromPos, float *toPos, float *triangle, float *intPoint);
int pointInTriangle(float *triangle, float *intPoint);


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
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		
		[self setupView];
		
		// Initialise our position and facing locations for gluLookAt().
		position[0] = 0.0;
		position[1] = 0.0;
		position[2] = 10.0;
		facing[0] = 0.0;
		facing[1] = 0.0;
		facing[2] = 8.0;
    }
    return self;
}

// Simple triangle for collision detection
const GLfloat triangleVerts[] = {
	0.0, 1.5, 0.0,
	-1.5, -1.5, 0.0,
	1.5, -1.5, 0.0
};


- (void)drawView {
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	glLoadIdentity();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[self handleTouches];
	gluLookAt(position[0], position[1], position[2], facing[0], facing[1], facing[2], 0, 1, 0);
	
	glColor4f(1.0, 0.0, 0.0, 1.0);
	glVertexPointer(3, GL_FLOAT, 0, triangleVerts);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 3);
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (void)setupView {
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 25;
    GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
	
    glClearColor(0.0, 0.0, 0.0, 0.0);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
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
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self
														 selector:@selector(drawView) userInfo:nil repeats:YES];
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
    
	// This vector gives us our direction. We use it to determine collision with walls.
    GLfloat vector[3];
    vector[0] = facing[0] - position[0];
    vector[1] = facing[1] - position[1];
    vector[2] = facing[2] - position[2];
	
	GLfloat destLocation[3];
    
    switch (currentMovement) {
        case MTWalkForward:
			
			// First get our destination location as if we have just completed the move.
			destLocation[0] = position[0] + vector[0] * WALK_SPEED;
			destLocation[1] = position[1] + vector[1] * WALK_SPEED;
			destLocation[2] = position[2] + vector[2] * WALK_SPEED;
			
			// Now check to see if we cross the triangle's plane
			float distanceFrom = locationToPlane((float *)triangleVerts, position);
			float distanceAfter = locationToPlane((float *)triangleVerts, destLocation);
			if ((distanceFrom * distanceAfter) < 0) {
				// They differ in sign. Therefore, we cross the plane
				float intPoint[3];
				intersectWithPlane(position, destLocation, (float *) triangleVerts, intPoint);
				if (pointInTriangle((float *)triangleVerts, intPoint)) {
					NSLog(@"Collision: %f  %f  %f", position[0], position[1], position[2]);
					return; // Don't move.
				}
			}
			
			position[0] += vector[0] * WALK_SPEED;
			position[2] += vector[2] * WALK_SPEED;
			facing[0] += vector[0] * WALK_SPEED;
			facing[2] += vector[2] * WALK_SPEED; 
			break;
			
        case MTWAlkBackward:
			
			// Do a quick test to see if all is ok to move.
			destLocation[0] = position[0] - vector[0] * WALK_SPEED;
			destLocation[1] = position[1] - vector[1] * WALK_SPEED;
			destLocation[2] = position[2] - vector[2] * WALK_SPEED;
			
			position[0] = destLocation[0];
			position[1] = destLocation[1];
			position[2] = destLocation[2];
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

@end

#pragma mark Collision detection functions

#define CROSS(dest, v1, v2)   \
dest[0] = v1[1]*v2[2] - v1[2]*v2[1]; \
dest[1] = v1[2]*v2[0] - v1[0]*v2[2]; \
dest[2] = v1[0]*v2[1] - v1[1]*v2[0];

#define DOT(v1, v2) (v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2])

#define VECT_ADD(dest, v1, v2) \
dest[0] = v1[0] + v2[0]; \
dest[1] = v1[1] + v2[1]; \
dest[2] = v1[2] + v2[2];

#define VECT_SUB(dest, v1, v2) \
dest[0] = v1[0] - v2[0]; \
dest[1] = v1[1] - v2[1]; \
dest[2] = v1[2] - v2[2];


// Distance to plane. Determines the distance from one point to the next in relation to the plane. QaD way of testing if
//  our path will pass through a plane.

void triangleNormal(float triangle[9], float normal[3]) {
	float triEdge1[3], triEdge2[3];
	// First get the Vector on the triangle from point 1 to point 2
	triEdge1[0] = triangle[3] - triangle[0];		// P2(X) - P1(X)
	triEdge1[1] = triangle[4] - triangle[1];		// Y
	triEdge1[2] = triangle[5] - triangle[2];		// Z
	
	// Now get the vector of the edge formed by point 2 to point 3.
	triEdge2[0] = triangle[6] - triangle[3];		// X
	triEdge2[1] = triangle[7] - triangle[4];		// Y
	triEdge2[2] = triangle[8] - triangle[5];		// Z
	
	// To get the normal of the triangle, we get the CROSS product between the two vertices we just calculated.
	normal[0] = (triEdge1[1] * triEdge2[2]) - (triEdge1[2] * triEdge2[1]);
	normal[1] = (triEdge1[2] * triEdge2[0]) - (triEdge1[0] * triEdge2[2]);
	normal[2] = (triEdge1[0] * triEdge2[1]) - (triEdge1[1] * triEdge2[0]);	
}

float locationToPlane(float triangle[3], float againstLocation[3]) {
    
    // Calculate the normal of the triangle. Usually, you'd store this in the data array.
    float normal[3];
    triangleNormal(triangle, normal);
    
    // Since we are treating the triangle as a plane, we need the plane's special "D".
    float A = normal[0] * triangle[0];
    float B = normal[1] * triangle[1];
    float C = normal[2] * triangle[2];
    float D = A + B + C;                // This is the equation for a plane.
    
    return DOT(normal, againstLocation) + D;
}

void intersectWithPlane(float fromPos[], float toPos[], float triangle[], float intPoint[]) {
	float normal[3];
	triangleNormal(triangle, normal);
	// Now we want the vector for the line.
	float lineVector[3];
	lineVector[0] = toPos[0] - fromPos[0];
	lineVector[1] = toPos[1] - fromPos[1];
	lineVector[2] = toPos[2] - fromPos[2];
	
	// Now we can start processing all this information. We have the normal of the triangle and a vector
	//  indicating our direction. Now we can begin to detect if our movement will pass through the triangle.
	//  Start by calculating the dot product between the plane's normal and the movement vector
	float a = DOT(lineVector, normal);
	
	// This should not occur but is here to avoid any possible divide by zero errors. Actually, the only
	//   way this can occur is if we are travelling parallel to the plane so it means that this function
	//	 has been called without passing the plane intersect test.
	if (a == 0) {
		intPoint[0] = fromPos[0];
		intPoint[1] = fromPos[1];
		intPoint[2] = fromPos[2];
		return;
	}
	
	float b[3];
	
	float distance = locationToPlane(triangle, fromPos);
	b[0] = lineVector[0] * (distance / a);
	b[1] = lineVector[1] * (distance / a);
	b[2] = lineVector[2] * (distance / a);
	VECT_SUB(intPoint, fromPos, b)
}

int pointInTriangle(float triangle[], float intPoint[]) {
	float angleSum = 0.0;
	float segment1[4], segment2[4], segment3[4];		// There will be three segments, one for each point on the triangle
	// There are four elements to each array. First three are the vertex, fourth one is the length
	float *triVert;
	triVert = &triangle[3];
	VECT_SUB(segment1, triangle, intPoint)
	VECT_SUB(segment2, triVert, intPoint)
	triVert = &triangle[6];
	VECT_SUB(segment3, triVert, intPoint)
	
	// Calculate the segment length
	segment1[3] = sqrt(segment1[0]*segment1[0] + segment1[1]*segment1[1] + segment1[2]*segment1[2]);
	segment2[3] = sqrt(segment2[0]*segment2[0] + segment2[1]*segment2[1] + segment2[2]*segment2[2]);
	segment3[3] = sqrt(segment3[0]*segment3[0] + segment3[1]*segment3[1] + segment3[2]*segment3[2]);
	
	if ((segment1[3] * segment2[3]) <= 0) {
		// Point is on boundary so include
		return 1;
	}
	if ((segment2[3] * segment3[3]) <= 0) {
		// Point is on boundary
		return 1;
	}
	if ((segment3[3] * segment1[3]) <= 0) {
		return 1;
	}
	
	// Now all the cheap calls are out of the way, time for the expensive cos()
	float cosAngle = (DOT(segment1, segment2)) / (segment1[3] * segment2[3]);
	angleSum = acos(cosAngle);
	
	cosAngle = (DOT(segment2, segment3)) / (segment2[3] * segment3[3]);
	angleSum += acos(cosAngle);
	
	cosAngle = (DOT(segment3, segment1)) / (segment3[3] * segment1[3]);
	angleSum += acos(cosAngle);
	
	// Now we look for 360º Need to allow a little tolerance
	if ((angleSum >= (2*M_PI - 0.0001)) && (angleSum <= (2*M_PI + 0.0001))) {
		return 1;
	}
	return 0;
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




