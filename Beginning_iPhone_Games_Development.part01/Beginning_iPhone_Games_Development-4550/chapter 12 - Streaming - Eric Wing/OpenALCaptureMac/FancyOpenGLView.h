//
//  ScopeView.h
//  OpenALCaptureMac
//
//  Created by Eric Wing on 7/8/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#define USE_COREVIDEO_TIMER

#import <Cocoa/Cocoa.h>
#ifdef USE_COREVIDEO_TIMER
#import <CoreVideo/CoreVideo.h>
#endif	


// Fancier OpenGLView that has timer callbacks and sets up a lot of useful things
@interface FancyOpenGLView : NSOpenGLView
{
#ifdef USE_COREVIDEO_TIMER
    CVDisplayLinkRef displayLink; // display link for managing rendering thread
#else
	// This timer is used to trigger animation callbacks since everything is event driven.
	NSTimer* animationTimer;
#endif	
	// Flags to help track whether ctrl-clicking or option-clicking is being used
	BOOL isUsingCtrlClick;
	BOOL isUsingOptionClick;
	
	// Flag to track whether the OpenGL multithreading engine is enabled or not
	BOOL isUsingMultithreadedOpenGLEngine;
}

// My custom static method to create a basic pixel format
+ (NSOpenGLPixelFormat*) basicPixelFormat;


// Official init methods
- (id) initWithFrame:(NSRect)frame_rect pixelFormat:(NSOpenGLPixelFormat*)pixel_format;
- (id) initWithCoder:(NSCoder*)the_coder;
- (id) initWithFrame:(NSRect)frame_rect;

// Official function, overridden by this class to prevent flashing/tearing when in splitviews, scrollviews, etc.
- (void) renewGState;



// Official/Special NSOpenGLView method that gets called for you to prepare your OpenGL state.
- (void) prepareOpenGL;
// Class dealloc method
- (void) dealloc;
- (void) finalize;

// Official methods for view stuff and drawing
- (BOOL) isOpaque;
- (void) resizeViewport;
- (void) reshape;
- (void) drawRect:(NSRect)the_rect;


// Method you should subclass to do your OpenGL drawing in.
// drawRect: calls this method. By doing so,
// [[self openGLContext] makeCurrentContext]; has been called before this method,
// and drawRect will call [[self openGLContext] flushBuffer];
// Don't bother calling [super renderScene];
- (void) renderScene;

@end
