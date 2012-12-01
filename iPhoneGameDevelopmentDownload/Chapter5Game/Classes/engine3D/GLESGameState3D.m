//
//  GLESGameState.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLESGameState3D.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import "ResourceManager.h"

//primary context for all opengl calls.  Set in setup2D, should be cleared in teardown.
EAGLContext* gles_context;

//these next 3 vars should really be tied to the state that we get bound to.  Since we only have
//one set of these for now, there is a white flash when changing between two GLESGameStates.
GLuint					gles_framebuffer;
GLuint					gles_renderbuffer;
GLuint					gles_depthRenderbuffer;
CGSize					_size;

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@implementation GLESGameState3D

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
{
    if (self = [super initWithFrame:frame andManager:pManager]) {
        // Initialization code
		[self bindLayer];
		endgame_state = 0;
		endgame_complete_time = 0.0f;
    }
    return self;
}

//initialize is called automatically before the class gets any other message, per from http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
		[GLESGameState3D setup];
    }
}

//initialize opengles, and set up the camera for 2d rendering.  This should be called before any other
//opengl calls.
+ (void) setup {
	//create and set the gles context.  All opengl calls are done relative to a context, so it
	//is important to set the context before anything else.  
	gles_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	[EAGLContext setCurrentContext:gles_context];
	
	glGenRenderbuffersOES(1, &gles_renderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, gles_renderbuffer);
	
	glGenFramebuffersOES(1, &gles_framebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, gles_framebuffer);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, gles_renderbuffer);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE); //todo: benchmark this.
	
	//Set the OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	const GLfloat			//lightShininess = 100.0,
	zNear = 0.1,
	zFar = 3000.0, //probably should be done in substates.
	fieldOfView = 60.0;
	GLfloat size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	CGRect rect = CGRectMake(0, 0, 320, 480);
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
	
	//Make the OpenGL modelview matrix the default
	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);

}

//Set our opengl context's output to the underlying gl layer of this gamestate.
//This should be called during the construction of any state that wants to do opengl rendering.
//Only the most recent caller will get opengl rendering.
- (BOOL) bindLayer {
	CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
	
	NSLog(@"layer %@", eaglLayer);
	
	//set up a few drawing properties.  App will run and display without this line, but the properties
	//here should make it go faster.  todo: benchmark this.
	[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil]];
	
	if(![EAGLContext setCurrentContext:gles_context]) {
		return NO;
	}
	
	//disconnect any existing render storage.  Has no effect if there is no existing storage.
	//I have no idea if this leaks.  I'm pretty sure that this class shouldn't be responsible for
	//freeing the previous eaglLayer, as that should be handled by the view which contains that layer.
	[gles_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:nil];
	
	//connect our renderbuffer to the eaglLayer's storage.  This allows our opengl stuff to be drawn to
	//the presented layer (and thus, the screen) when presentRenderbuffer is called.
	if(![gles_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer]) {
		glDeleteRenderbuffersOES(1, &gles_renderbuffer); //probably should exit the app here.
		return NO;
	}
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	//this must be done after context renderbufferStorage:fromDrawable: call above.  otherwise everything is crush.
	//todo: release. -joe
	GLint backingWidth, backingHeight;
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	glGenRenderbuffersOES(1, &gles_depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, gles_depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, gles_depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		DebugLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}

	return YES;
}

- (void) startDraw{
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, gles_renderbuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, gles_framebuffer);
}

//finish opengl calls and send the results to the screen.  should be
//called to end the rendering of a frame.
- (void) swapBuffers
{
	EAGLContext *oldContext = [EAGLContext currentContext];
	GLuint oldRenderbuffer;
	
	if(oldContext != gles_context)
		[EAGLContext setCurrentContext:gles_context];
	
	glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, gles_renderbuffer);
	
	//NSLog(@"oldrenderbuffer %d, renderbuffer %d", oldRenderbuffer, _renderbuffer);
	
	glFinish();
	
	if(![gles_context presentRenderbuffer:GL_RENDERBUFFER_OES])
		printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
	
}

+ (void) teardown {
	[gles_context release];
}

- (CGPoint) touchPosition:(UITouch*)touch {
	CGPoint point = [touch locationInView:self];
	point.y = self.frame.size.height-point.y; //convert to opengl coordinates.
	return point;
}

@end
