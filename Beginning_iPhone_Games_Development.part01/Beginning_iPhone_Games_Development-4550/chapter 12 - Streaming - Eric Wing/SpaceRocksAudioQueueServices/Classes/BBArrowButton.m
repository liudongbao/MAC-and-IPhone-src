//
//  BBArrowButton.m
//  SpaceRocks
//
//  Created by ben smith on 7/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBArrowButton.h"

#pragma mark arrow button mesh
static NSInteger BBArrowButtonOutlineVertexesCount = 14;
static CGFloat BBArrowButtonOutlineVertexes[28] = {-0.25, 0.0, 0.25, 0.0,
0.25, 0.0, 0.1, 0.25,0.25, 0.0, 0.1,-0.25, -0.5,-0.5,-0.5, 0.5, -0.5, 0.5, 
0.5, 0.5, 0.5, 0.5, 0.5,-0.5, 0.5,-0.5,-0.5,-0.5};
static GLenum BBArrowButtonOutlineRenderStyle = GL_LINES;
static CGFloat BBArrowButtonOutlineColorValues[56] = 
{1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0,
1.0,1.0,1.0,1.0, 1.0,1.0,1.0,1.0};


@implementation BBArrowButton
-(void)setNotPressedVertexes
{
	mesh.vertexes = BBArrowButtonOutlineVertexes;
	mesh.renderStyle = BBArrowButtonOutlineRenderStyle;
	mesh.vertexCount = BBArrowButtonOutlineVertexesCount;	
	mesh.colors = BBArrowButtonOutlineColorValues;
}
@end
