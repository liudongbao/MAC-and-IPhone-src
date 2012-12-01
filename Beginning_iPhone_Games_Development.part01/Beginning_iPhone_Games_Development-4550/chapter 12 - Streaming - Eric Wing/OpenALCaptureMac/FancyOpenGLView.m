//
//  FancyOpenGLView.m
//  OpenALCaptureMac
//
//  Created by Eric Wing on 7/8/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "FancyOpenGLView.h"


#include <OpenGL/gl.h>
#include <OpenGL/glu.h> // handy for gluErrorString

// Needed for Multithreaded OpenGL Engine (sysctlbyname for num CPUs)
#include <sys/types.h>
#include <sys/sysctl.h>
#include <OpenGL/OpenGL.h> // for CoreOpenGL (CGL) for Multithreaded OpenGL Engine

// for fullscreen transitions
/*
 #import <QuartzCore/CAAnimation.h>
 #import <QuartzCore/CoreImage.h>
 */
// This is optional. This allows memory for things like textures and displaylists to be shared among different contexts.
#define VIEWER_USE_SHARED_CONTEXTS
#ifdef VIEWER_USE_SHARED_CONTEXTS
static NSOpenGLContext* s_sharedOpenGLContext = NULL;
#endif // VIEWER_USE_SHARED_CONTEXTS




@interface FancyOpenGLView ()
// Private init helper methods
- (void) initSharedOpenGLContext;
- (void) commonInit;
- (void) initAnimationTimer;
// My custom method to handle timer callbacks
#ifndef USE_COREVIDEO_TIMER
- (void) animationCallback;
#endif
@end

#ifdef USE_COREVIDEO_TIMER
// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef display_link, const CVTimeStamp* now_time, const CVTimeStamp* output_time, CVOptionFlags flagsIn, CVOptionFlags* option_flags, void* user_data)
{
	NSOpenGLView* gl_view = (NSOpenGLView*)user_data;
	[gl_view drawRect:[gl_view frame]];
	return kCVReturnSuccess;
}
#endif

@implementation FancyOpenGLView


// My simple pixel format definition
+ (NSOpenGLPixelFormat*) basicPixelFormat
{
	NSOpenGLPixelFormatAttribute pixel_attributes[] =
	{
		NSOpenGLPFAWindow,
		NSOpenGLPFADoubleBuffer,  // double buffered
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)32, // depth buffer size in bits
		//		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)24, // Not sure if this helps
		//		NSOpenGLPFAAlphaSize, (NSOpenGLPixelFormatAttribute)8, // Not sure if this helps
		(NSOpenGLPixelFormatAttribute)nil
    };
    return [[[NSOpenGLPixelFormat alloc] initWithAttributes:pixel_attributes] autorelease];
}


////////////////////////////////////////////////////////////////////////
/////////////////////////// Init Stuff /////////////////////////////////
////////////////////////////////////////////////////////////////////////

/* This is the designated initializer for an NSOpenGLView. However, since I'm 
 * using Interface Builder to help, initWithCoder: is the initializer that gets called.
 * But for completeness, I implement this method here.
 */
- (id) initWithFrame:(NSRect)frame_rect pixelFormat:(NSOpenGLPixelFormat*)pixel_format
{
	self = [super initWithFrame:frame_rect pixelFormat:pixel_format];
	if(self)
	{
		[self commonInit];
	}
	return self;
}

/* Going through the IB palette, this initializer is calling instead of the designated initializer
 * initWithFrame:pixelFormat: 
 * But for some reason, the pixel format set in IB selected seems to be either ignored or is missing
 * a value I need. (The depth buffer looks too shallow to me and glErrors are triggered.)
 * So I explicitly set the pixel format inside here (overriding the IB palette options).
 * This probably should be investigated, but since IB is getting an overhaul for Leopard,
 * I'll wait on this for now.
 */
- (id) initWithCoder:(NSCoder*)the_coder
{
	self = [super initWithCoder:the_coder];
	if(self)
	{
		NSOpenGLPixelFormat* pixel_format = [[self class] basicPixelFormat];
		[self setPixelFormat:pixel_format];
		[self commonInit];
	}
	return self;
}

/* Some generic code expecting regular NSView's may call this initializer instead of the specialized NSOpenGLView designated initializer.
 * I override this method here to make sure it does the right thing.
 */
- (id) initWithFrame:(NSRect)frame_rect
{
	self = [super initWithFrame:frame_rect pixelFormat:[[self class] basicPixelFormat]];
	if(self)
	{
		[self commonInit];
	}
	return self;
}


// My custom methods to centralize common init stuff
- (void) commonInit
{
	isUsingCtrlClick = NO;
	isUsingOptionClick = NO;
	isUsingMultithreadedOpenGLEngine = NO;
	
	[self initSharedOpenGLContext];
	
	
	// Register for Drag and Drop
	//	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSURLPboardType, nil]];
	
    // Add minification observer so we can set the Dock picture since OpenGL views don't do this automatically for us.
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareForMiniaturization:) name:NSWindowWillMiniaturizeNotification object:nil];
	
}

/* Optional: This will setup shared OpenGL contexts so resources like textures, etc, can be shared/reused
 * by multiple instances of SimpleViwerCocoa views.
 */
- (void) initSharedOpenGLContext
{
#ifdef VIEWER_USE_SHARED_CONTEXTS
	
	NSOpenGLContext* this_views_opengl_context = nil;
	
	// create a context the first time through
	if(s_sharedOpenGLContext == NULL)
	{
		s_sharedOpenGLContext = [[NSOpenGLContext alloc]
								 initWithFormat:[[self class] basicPixelFormat]
								 shareContext:nil];
		
	}
	
	this_views_opengl_context = [[NSOpenGLContext alloc]
								 initWithFormat:[[self class] basicPixelFormat]
								 shareContext:s_sharedOpenGLContext];
 	[self setOpenGLContext:this_views_opengl_context];
	//	[this_views_opengl_context makeCurrentContext];
#endif // VIEWER_USE_SHARED_CONTEXTS
}

// Core Video based timer must be done after we have a valid GL context
- (void) initAnimationTimer
{
#ifdef USE_COREVIDEO_TIMER

	
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
    // Set the display link for the current renderer
    CGLContextObj cgl_context = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cgl_pixel_format = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cgl_context, cgl_pixel_format);
	
    // Activate the display link
    CVDisplayLinkStart(displayLink);
#else

	// Cocoa is event driven, so by default, there is nothing to trigger redraws for animation.
	// The easiest way to animate is to set a repeating NSTimer which triggers a redraw.
	
	animationTimer = [NSTimer
					  scheduledTimerWithTimeInterval:1.0/60.0 // fps
					  target:self
					  selector:@selector(animationCallback)
					  userInfo:nil
					  repeats:YES];
	
	[animationTimer retain];
	
	// For single threaded apps like this one,
	// Cocoa seems to block timers or events sometimes. This can be seen
	// when I'm animating (via a timer) and you open an popup box or move a slider.
	// Apparently, sheets and dialogs can also block (try printing).
	// To work around this, Cocoa provides different run-loop modes. I need to 
	// specify the modes to avoid the blockage.
	// NSDefaultRunLoopMode seems to be the default. I don't think I need to explicitly
	// set this one, but just in case, I will set it anyway.
	[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
	// This seems to be the one for preventing blocking on other events (popup box, slider, etc)
	[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSEventTrackingRunLoopMode];
	// This seems to be the one for dialogs.
	[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSModalPanelRunLoopMode];
	
#endif

}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

#ifdef USE_COREVIDEO_TIMER	
    // Release the display link
	CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
#else
	[animationTimer invalidate];
	[animationTimer release];
#endif

	[super dealloc];
}

- (void) finalize
{
#ifdef USE_COREVIDEO_TIMER	
	CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
#endif
	[super finalize];
}

/* NSOpenGLView defines this method to be called (only once) after the OpenGL
 * context is created and made the current context. It is intended to be used to setup
 * your initial OpenGL state. This seems like a good place to initialize the 
 * OSG stuff. This method exists in 10.3 and later. If you are running pre-10.3, you
 * must manually call this method sometime after the OpenGL context is created and 
 * made current, or refactor this code.
 */
- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
	// The NSOpenGLCPSwapInterval seems to be vsync. If 1, buffers are swapped with vertical refresh.
	// If 0, flushBuffer will execute as soon as possible.
	//	long swap_interval = 1 ;
	
	// Leopard changes long* to const GLint*
	GLint swap_interval = 1 ;
	
	
    [[self openGLContext] setValues:&swap_interval forParameter:NSOpenGLCPSwapInterval];
	
#if 1
	// Try new multithreaded OpenGL engine?
	// See Technical Note TN2085 Enabling multi-threaded execution of the OpenGL framework
	// http://developer.apple.com/technotes/tn2006/tn2085.html
	// For this simple viewer, you are probably not going to see a speed boost, but possibly a speed hit,
	// since we probably don't have much data to dispatch,
	// but it is enabled anyway for demonstration purposes.
	uint64_t num_cpus = 0;
	size_t num_cpus_length = sizeof(num_cpus);
	// Multithreaded engine only benefits with muliple CPUs, so do CPU count check
	// I've been told that Apple has started doing this check behind the scenes in some version of Tiger.
	if(sysctlbyname("hw.activecpu", &num_cpus, &num_cpus_length, NULL, 0) == 0)
	{
		//		NSLog(@"Num CPUs=%d", num_cpus);
		if(num_cpus >= 2)
		{
			// Cleared to enable multi-threaded engine
			// kCGLCEMPEngine may not be defined before certain versions of Tiger/Xcode,
			// so use the numeric value 313 instead to keep things compiling.
			CGLError error_val = CGLEnable((CGLContextObj)[[self openGLContext] CGLContextObj], (CGLContextEnable)(313));
			if(error_val != 0)
			{
				// The likelihood of failure seems quite high on older hardware, at least for now.
				// NSLog(@"Failed to enable Multithreaded OpenGL Engine: %s", CGLErrorString(error_val));
				isUsingMultithreadedOpenGLEngine = NO;
			}
			else
			{
				// NSLog(@"Success! Multithreaded OpenGL Engine activated!");
				isUsingMultithreadedOpenGLEngine = YES;
			}
		}
		else
		{
			isUsingMultithreadedOpenGLEngine = NO;
		}
	}
#endif
	// This is also might be a good place to setup OpenGL state that OSG doesn't control.
	glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	
//    glClearColor(0.0, 0.5, 0.9, 1.0);

	/*
	 GLint maxbuffers[1];
	 glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS_EXT, maxbuffers);
	 NSLog(@"GL_MAX_COLOR_ATTACHMENTS=%d", maxbuffers[0]);
	 */
	
	// We need to tell the osgViewer what the viewport size is
	[self resizeViewport];

	[self initAnimationTimer];

	
}

/* disableScreenUpdatesUntilFlush was introduced in Tiger. It will prevent
 * unnecessary screen flashing caused by NSSplitViews or NSScrollviews.
 * From Apple's release notes:
 
 NSWindow -disableScreenUpdatesUntilFlush API (Section added since WWDC)
 
 When a view that renders to a hardware surface (such as an OpenGL view) is placed in an NSScrollView or NSSplitView, there can be a noticeable flicker or lag when the scroll position or splitter position is moved. This happens because each move of the hardware surface takes effect immediately, before the remaining window content has had the chance to draw and flush.
 
 To enable applications to eliminate this visual artifact, Tiger AppKit provides a new NSWindow message, -disableScreenUpdatesUntilFlush. This message asks a window to suspend screen updates until the window's updated content is subsequently flushed to the screen. This message can be sent from a view that is about to move its hardware surface, to insure that the hardware surface move and window redisplay will be visually synchronized. The window responds by immediately disabling screen updates via a call to NSDisableScreenUpdates(), and setting a flag that will cause it to call NSEnableScreenUpdates() later, when the window flushes. It is permissible to send this message to a given window more than once during a given window update cycle; the window will only suspend and re-enable updates once during that cycle.
 
 A view class that renders to a hardware surface can send this message from an override of -renewGState (a method that is is invoked immediately before the view's surface is moved) to effectively defer compositing of the moved surface until the window has finished drawing and flushing its remaining content.
 A -respondsToSelector: check has been used to provide compatibility with previous system releases. On pre-Tiger systems, where NSWindow has no -disableScreenUpdatesUntilFlush method, the -renewGState override will have no effect.
 */
- (void) renewGState
{
    NSWindow* the_window = [self window];
    if([the_window respondsToSelector:@selector(disableScreenUpdatesUntilFlush)])
	{
		[the_window disableScreenUpdatesUntilFlush];
    }
    [super renewGState];
}

#if 0
/* When you minimize an app, you usually can see its shrunken contents 
 * in the dock. However, an OpenGL view by default only produces a blank
 * white window. So we use this method to do an image capture of our view
 * which will be used as its minimized picture.
 * (A possible enhancement to consider is to update the picture over time.)
 */
- (void) prepareForMiniaturization:(NSNotification*)notification
{
	[[self openGLContext] makeCurrentContext];
	NSBitmapImageRep* ns_image_rep = [self renderOpenGLSceneToFramebuffer];
	if([self lockFocusIfCanDraw])
	{
		[ns_image_rep draw];
		[self unlockFocus];
		[[self window] flushWindow];
	}
}
#endif

/* Allow people to easily query if the multithreaded OpenGL engine is activated.
 */
- (BOOL) isUsingMultithreadedOpenGLEngine
{
	return isUsingMultithreadedOpenGLEngine;
}


////////////////////////////////////////////////////////////////////////
/////////////////////////// End Init Stuff /////////////////////////////
////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////
/////////////////////////// View and Draw Stuff ////////////////////////
////////////////////////////////////////////////////////////////////////

#ifndef USE_COREVIDEO_TIMER
// This method is periodically called by my timer.
- (void) animationCallback
{
	// Simply notify Cocoa that a drawRect needs to take place.
	// Potential optimization is to query the OSG stuff to find out if a redraw is actually necessary.
	[self setNeedsDisplay:YES];
}
#endif

// This is an optional optimization. This states you don't have a transparent view/window.
// Obviously don't use this or set it to NO if you intend for your view to be see-through.
- (BOOL) isOpaque
{
	return YES;
}

// Resolution Independent UI is coming... (Tiger's Quartz Debug already has the tool.)
// We must think in 'point sizes', not pixel sizes, so a conversion is needed for OpenGL.
- (void) resizeViewport
{
	NSSize size_in_points = [self bounds].size;
	// This coordinate system conversion seems to make things work with Quartz Debug.
	NSSize size_in_window_coordinates = [self convertSize:size_in_points toView:nil];
//	theViewer->getEventQueue()->windowResize(0, 0, size_in_window_coordinates.width, size_in_window_coordinates.height);
//	graphicsWindow->resized(0, 0, size_in_window_coordinates.width, size_in_window_coordinates.height);
	glViewport(0, 0, size_in_window_coordinates.width, size_in_window_coordinates.height);
}

// For window resize
- (void) reshape
{
	[super reshape];
	[self resizeViewport];
}

// This is the code that actually draws.
// Remember you shouldn't call drawRect: directly and should use setNeedsDisplay:YES
// with the exception of a Core Video callback.
// This is so the operating system can optimize when a draw is actually needed.
// (e.g. No sense drawing when the application is hidden.)
- (void) drawRect:(NSRect)the_rect
{
	// Doesn't work with my Core Video callback design
//	if([[NSGraphicsContext currentContext] isDrawingToScreen])
//	{
		[[self openGLContext] makeCurrentContext];

//		theViewer->frame();
		[self renderScene];

		[[self openGLContext] flushBuffer];
//	}
#if 0
	else // This is usually the print case
	{
		[[self openGLContext] makeCurrentContext];
		
		// FIXME: We should be computing a size that fits best to the paper target
		NSSize size_in_points = [self bounds].size;
		NSSize size_in_window_coordinates = [self convertSize:size_in_points toView:nil];
		NSBitmapImageRep * bitmap_image_rep = [self renderOpenGLSceneToFramebufferAsFormat:GL_RGB viewWidth:size_in_window_coordinates.width viewHeight:size_in_window_coordinates.height];
		
		NSImage* ns_image = [self imageFromBitmapImageRep:bitmap_image_rep];
		
		if(ns_image)
		{
			NSSize image_size = [ns_image size];
			[ns_image drawAtPoint:NSMakePoint(0.0, 0.0) 
						 fromRect: NSMakeRect(0.0, 0.0, image_size.width, image_size.height)
			 //				   operation: NSCompositeSourceOver
						operation: NSCompositeCopy
						 fraction: 1.0]; 	
		}
		else
		{
			NSLog(@"Image not valid");
		}
	}
#endif
}

// Expecting to be completely overridden by subclass
- (void) renderScene
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end
