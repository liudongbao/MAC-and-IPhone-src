//
//  ViewController.m
//  emptyTemplate
//
//  Created by James Sugrue on 10/27/11.
//  Copyright (c) 2011 SoftwareX. All rights reserved.
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "ViewController.h"
#import "GameController.h"
#import "AbstractSceneController.h"


@implementation ViewController

- (void)setup {
    glViewport(0, 0, 320, 480);
    sharedGameController = [GameController sharedGameController];
    sharedGameController.mainView = self;
}

- (void)draw
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
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
