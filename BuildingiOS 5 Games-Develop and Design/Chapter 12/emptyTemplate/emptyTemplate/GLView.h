//
//  GLView.h
//  emptyTemplate
//
//  Created by James Sugrue on 10/27/11.
//  Copyright (c) 2011 SoftwareX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class ViewController;

@interface GLView : UIView {
    GLint               backingWidth; 
    GLint               backingHeight;
    GLuint              frameBuffer; 
    GLuint              renderBuffer;
    GLuint              depthBuffer;
    
    NSInteger animationFrameInterval;
}

@property (nonatomic, retain)   EAGLContext *context;
@property (nonatomic, retain)   CADisplayLink *displayLink;
@property (readonly, nonatomic) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) IBOutlet ViewController *controller;

- (void)startAnimation;
- (void)stopAnimation;

@end
