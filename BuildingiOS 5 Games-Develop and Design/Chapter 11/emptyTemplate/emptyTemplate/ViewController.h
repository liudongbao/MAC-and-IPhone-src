//
//  ViewController.h
//  emptyTemplate
//
//  Created by James Sugrue on 10/27/11.
//  Copyright (c) 2011 SoftwareX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    GLuint      positionAttribute;
    GLuint      textureCoordinateAttribute;
    GLuint      matrixUniform;
    GLuint      textureUniform;
    
    GLuint program;
}

- (void)draw;
- (void)setup;

@end
