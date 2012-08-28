

#import "GLView.h"
#import "ViewController.h"

@implementation GLView

@synthesize controller, context, displayLink, animating;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)coder {    
    if (self = [super initWithCoder:coder]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        
        EAGLContext *theContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.context = theContext;
        
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            return nil;
        }        
        animating = NO;
        animationFrameInterval = 2;
    }
    return self;
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink setFrameInterval:animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        animating = YES;
    }
}
- (void)stopAnimation
{
    if (animating)
    {
        [displayLink invalidate];
        self.displayLink = nil;
        
        animating = NO;
    }
}

- (void)createBuffers {
    glGenFramebuffers(1, &frameBuffer);
    glGenRenderbuffers(1, &renderBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer); 
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    glGenRenderbuffers(1, &depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
}

- (void)destroyBuffers {
    glDeleteFramebuffers(1, &frameBuffer);
    frameBuffer = 0;
    glDeleteRenderbuffers(1, &renderBuffer);
    renderBuffer = 0;
    
    if(depthBuffer) 
    {
        glDeleteRenderbuffers(1, &depthBuffer);
        depthBuffer = 0;
    }
}

- (void)drawView
{    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    [controller draw];
    
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    [self destroyBuffers];
    [self createBuffers];
    [self drawView];
    
    
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    glViewport(0, 0, backingWidth, backingHeight);
    [controller setup];
}

@end
