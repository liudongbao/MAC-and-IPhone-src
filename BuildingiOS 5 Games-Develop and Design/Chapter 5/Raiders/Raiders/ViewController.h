//
//  ViewController.h
//  Raiders
//
//  Created by James Sugrue on 14/08/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GameController.h"

@interface ViewController : GLKViewController
{    
    GameController *sharedGameController;
}   

@end
