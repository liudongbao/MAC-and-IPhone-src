//
//  GLFunView.h
//  GLFun
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "OpenGLES2DView.h"

@class Texture2D;

@interface GLFunView : OpenGLES2DView {
    CGPoint firstTouch;
    CGPoint lastTouch;
    UIColor *currentColor;
    BOOL useRandomColor;
	
    ShapeType shapeType;
	
    Texture2D *sprite;
}
@property CGPoint firstTouch;
@property CGPoint lastTouch;
@property (nonatomic, retain) UIColor *currentColor;
@property BOOL useRandomColor;
@property ShapeType shapeType;
@property (nonatomic, retain) Texture2D *sprite;
@end
