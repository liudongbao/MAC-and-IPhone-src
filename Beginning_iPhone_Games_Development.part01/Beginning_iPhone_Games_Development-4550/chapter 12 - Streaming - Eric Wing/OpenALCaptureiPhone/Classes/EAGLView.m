//
//  EAGLView.m
//  OpenALCapture
//
//  Created by Eric Wing on 7/7/09.
//  Copyright PlayControl Software, LLC 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

//#define SCOPE_MAX_NUMBER_OF_POINTS 1536 // x-points to draw
#define SCOPE_MAX_NUMBER_OF_POINTS 2048 // x-points to draw
#define SCOPE_MAX_Y_RANGE 32768 // roughly the absolute max for a 16-bit int
#define NUMBER_OF_LINE_VERTICES SCOPE_MAX_NUMBER_OF_POINTS
#define NUMBER_OF_LINE_COMPONENTS_PER_VERTEX 2 // x and y


#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) initOpenGL;
- (void) renderScene;

@end


@implementation EAGLView

@synthesize context;

@synthesize dataDelegate;


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
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
		[self initOpenGL];
    }
    return self;
}


- (void) drawView
{
    
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

	[self renderScene];

    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    glViewport(0, 0, backingWidth, backingHeight);

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


- (void) startAnimation
{

	NSLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED = %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
#warning "In displayLink"
	if(displayLink)
	{
		return;
	}
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
	[displayLink retain];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	NSLog(@"using displayLink");
#else
#warning "In timer"
	if(animationTimer)
	{
		return;
	}
	animationTimer = [NSTimer
					  scheduledTimerWithTimeInterval:1.0/(60.0) // fps
					  target:self
					  selector:@selector(drawView)
					  userInfo:nil
					  repeats:YES];
	
	[animationTimer retain];
	NSLog(@"using timer");
	
#endif	
}


- (void) stopAnimation
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30100
	[displayLink invalidate];
	[displayLink release];
	displayLink = nil;
#else
	[animationTimer invalidate];
	[animationTimer release];
	animationTimer = nil;
#endif
}


- (void)dealloc {
    
    [self stopAnimation];
    
	glDeleteBuffers(1, &lineVBO);
	free(scopeData);
	free(scopeDataConverted);
	
	
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    [super dealloc];
}


- (void) initOpenGL
{
    [EAGLContext setCurrentContext:context];

	// This is also might be a good place to setup OpenGL state that OSG doesn't control.
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

	glClearColor(0.0, 0.0, 0.0, 1.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	//    gluOrtho2D(0, SCOPE_MAX_NUMBER_OF_POINTS, -SCOPE_MAX_Y_RANGE, SCOPE_MAX_Y_RANGE);
#if (TARGET_OS_IPHONE == 1) || (TARGET_IPHONE_SIMULATOR == 1)
    glOrthof(0.0f, SCOPE_MAX_NUMBER_OF_POINTS, -SCOPE_MAX_Y_RANGE, SCOPE_MAX_Y_RANGE, -1.0f, 1.0f);
#else
    glOrtho(0.0, SCOPE_MAX_NUMBER_OF_POINTS, -SCOPE_MAX_Y_RANGE, SCOPE_MAX_Y_RANGE, -1.0, 1.0);
#endif
    glMatrixMode(GL_MODELVIEW);
	
	// number of samples, size per sample
	// I know how many points I want to draw, and I also know that the OpenAL data is 16-bit.
	// So I cheat a little here and know to make the size 2.
	scopeData = (int8_t*)calloc(SCOPE_MAX_NUMBER_OF_POINTS, 2);
	scopeDataMaxArrayLength = SCOPE_MAX_NUMBER_OF_POINTS * 2;
	
	// times 2 because we need both an x and a y, not just y.
	// And we are going to use float for this array because OpenGL prefers float
	scopeDataConverted = (float*)calloc(SCOPE_MAX_NUMBER_OF_POINTS*2, sizeof(float));
	scopeDataConvertedMaxArrayLength = SCOPE_MAX_NUMBER_OF_POINTS * 2 * sizeof(float);
	
	// Setup all the x-values so it goes 0, 1, 2, ... which is good for plotting on a graph 
	for(int i=0; i<SCOPE_MAX_NUMBER_OF_POINTS;i+=1)
	{
		scopeDataConverted[2*i] = (float)i;
	}
	
	
	// allocate a new buffer
	glGenBuffers(1, &lineVBO);
	
	// bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, lineVBO);
	
	const GLsizeiptr vertex_size = NUMBER_OF_LINE_VERTICES*NUMBER_OF_LINE_COMPONENTS_PER_VERTEX*sizeof(GLfloat);
	
	// allocate enough space for the VBO
	glBufferData(GL_ARRAY_BUFFER, vertex_size, 0, GL_DYNAMIC_DRAW);
	
#if 0
	glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, scopeDataConverted); // start at index 0, to length of vertex_size
#else
	#if (TARGET_OS_IPHONE == 1) || (TARGET_IPHONE_SIMULATOR == 1)
		GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES); 
	#else
		GLvoid* vbo_buffer = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY); 
	#endif
	
	// transfer the vertex data to the VBO
	memcpy(vbo_buffer, scopeDataConverted, vertex_size);
	
	#if (TARGET_OS_IPHONE == 1) || (TARGET_IPHONE_SIMULATOR == 1)
		glUnmapBufferOES(GL_ARRAY_BUFFER);
	#else
		glUnmapBuffer(GL_ARRAY_BUFFER);
	#endif
#endif
	currentNumberOfSamples = SCOPE_MAX_NUMBER_OF_POINTS;
	
	
	// Describe to OpenGL where the vertex data is in the buffer
	glVertexPointer(2, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	
	
    glEnableClientState(GL_VERTEX_ARRAY);



}

- (void) renderScene
{

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	size_t number_of_bytes_read = 0;
	size_t bytes_per_sample = 0;
	if([self.dataDelegate respondsToSelector:@selector(dataArray:maxArrayLength:getBytesPerSample:)])
	{
		number_of_bytes_read = [self.dataDelegate dataArray:scopeData maxArrayLength:scopeDataMaxArrayLength getBytesPerSample:&bytes_per_sample];
	}
	if(0 == number_of_bytes_read)
	{
		// For entertainment purposes, we will draw the line in yellow when we don't update the VBO
		glColor4ub(255, 255, 0, 255);
		glBindBuffer(GL_ARRAY_BUFFER, lineVBO);
		glDrawArrays(GL_LINE_STRIP, 0, currentNumberOfSamples);
	}
	else
	{
		if(2 == bytes_per_sample)
		{
			// Because our array was originally 8-bits per element,
			// we'll cast an alias so we can grab 16-bits per element.
			int16_t* sample_array = (int16_t*)scopeData;
			
			// The OpenAL PCM data is only y-values, so
			// Copy all the values we got from OpenAL to the y-value spot in our x,y array
			// Also convert to float while we're at it.
			size_t number_of_samples = number_of_bytes_read/bytes_per_sample;
			currentNumberOfSamples = number_of_samples;
			for(int i=0; i<number_of_samples;i++)
			{
				scopeDataConverted[2*i+1] = (float)sample_array[i];
			}
		}
		/*
		 // Not implemented, but in theory if we wanted to handle the general case...		
		 else if(1 == bytes_per_sample)
		 {
		 }
		 else if(4 == bytes_per_sample)
		 {
		 }
		 */
		glBindBuffer(GL_ARRAY_BUFFER, lineVBO);
		
		const GLsizeiptr vertex_size = currentNumberOfSamples*NUMBER_OF_LINE_COMPONENTS_PER_VERTEX*sizeof(GLfloat);
		
		// Which way is faster? Should benchmark someday.
#if 1
	glBufferData(GL_ARRAY_BUFFER, vertex_size, NULL, GL_DYNAMIC_DRAW); // tell OpenGL I no longer care for the contents of the old buffer
	#if (TARGET_OS_IPHONE == 1) || (TARGET_IPHONE_SIMULATOR == 1)
		GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES); 
	#else
		GLvoid* vbo_buffer = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY); 
	#endif
		
		// transfer the vertex data to the VBO
		memcpy(vbo_buffer, scopeDataConverted, vertex_size);
		
	#if (TARGET_OS_IPHONE == 1) || (TARGET_IPHONE_SIMULATOR == 1)
		glUnmapBufferOES(GL_ARRAY_BUFFER);
	#else
		glUnmapBuffer(GL_ARRAY_BUFFER);
	#endif
#else
		glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, scopeDataConverted);
#endif
		
		// For entertainment purposes, we will draw the line in red when we update the VBO
		glColor4ub(255, 0, 0, 255);
		glDrawArrays(GL_LINE_STRIP, 0, currentNumberOfSamples);
		
	}
	
	
}


@end
