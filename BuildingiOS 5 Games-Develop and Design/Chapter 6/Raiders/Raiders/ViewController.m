//
//  ViewController.m
//  Raiders
//
//  Created by James Sugrue on 14/08/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "ViewController.h"
#import "GameController.h"
#import "AbstractSceneController.h"

@interface ViewController () {
    
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

@synthesize context = _context;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self setupGL];
    sharedGameController = [GameController sharedGameController];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
        return YES;
    
    return NO;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [sharedGameController updateWorld];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [sharedGameController playCurrentScene];
    
}

#pragma mark - Touch based methods

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	// Pass touch events onto the current scene
	[[sharedGameController currentScene] touchesEnded:touches withEvent:event view:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[sharedGameController currentScene] touchesMoved:touches withEvent:event view:self.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[sharedGameController currentScene] touchesBegan:touches withEvent:event view:self.view];
}

@end
