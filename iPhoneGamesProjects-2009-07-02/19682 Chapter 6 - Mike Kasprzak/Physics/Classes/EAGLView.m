//
//  EAGLView.m
//  Physics
//
//  Created by Michael Kasprzak on 16/02/09.
//  Copyright Sykhronics Entertainment 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#include "../Source/UnixTime.h"
#include "../Source/game.h"


#define USE_DEPTH_BUFFER 0

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

extern int ScreenWidth;
extern int ScreenHeight;
int ScreenWidth;
int ScreenHeight;

TIMEVALUE WorkTime;

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
        
		ScreenWidth = 320;
		ScreenHeight = 480;
		
		Game_Initialize();
		
		animationInterval = 1.0 / 60.0;
		
		SetFramesPerSecond( 60 );
		WorkTime = GetTimeNow();
    }
    return self;
}

Vector2D ActiveTouchPos;
int ActiveTouchValue;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	int CurrentTouch = 0;
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInView:self];
		
		/* First touch only */
		if ( CurrentTouch == 0 ) {
			ActiveTouchPos.x = touchPoint.x;
			ActiveTouchPos.y = touchPoint.y;
			
			ActiveTouchValue = 1;
		}
		
		CurrentTouch++;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	int CurrentTouch = 0;
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInView:self];
		
		/* First touch only */
		if ( CurrentTouch == 0 ) {
			ActiveTouchPos.x = touchPoint.x;
			ActiveTouchPos.y = touchPoint.y;
		}
		
		CurrentTouch++;
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	int CurrentTouch = 0;
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInView:self];
		
		/* First touch only */
		if ( CurrentTouch == 0 ) {
			ActiveTouchPos.x = touchPoint.x;
			ActiveTouchPos.y = touchPoint.y;
			
			ActiveTouchValue = 0;
		}
		
		CurrentTouch++;
	}
}


Vector2D TouchPos;
Vector2D Orientation;

int TouchOldValue;
int TouchValue;

void Update_Input() {
	/* Copy the Active Touches */
	TouchPos.x = ActiveTouchPos.x - (ScreenWidth >> 1);
	TouchPos.y = ActiveTouchPos.y - (ScreenHeight >> 1);
	
	TouchOldValue = TouchValue;
	TouchValue = ActiveTouchValue;

	extern float AccelerometerX;
	extern float AccelerometerY;
//	extern float AccelerometerZ;
	
	Orientation.x = AccelerometerX;
	Orientation.y = -AccelerometerY;
}


int TouchChanged() {
	return (TouchValue ^ TouchOldValue);
}

int TouchIsDown() {
	return (TouchValue ^ TouchOldValue) & TouchValue;
}

int TouchIsUp() {
	return (TouchValue ^ TouchOldValue) & TouchOldValue;
}

int Touching() {
	return TouchValue;
}


- (void)drawView {
	TIMEVALUE TimeDiff = SubtractTime( GetTimeNow(), WorkTime );
	int WorkFrames = GetFrames( &TimeDiff );

	while ( WorkFrames-- ) {
		Update_Input();
		Game_Work();
		AddFrame( &WorkTime );
	}
	
	[EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);

	Game_Draw();
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
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


- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
