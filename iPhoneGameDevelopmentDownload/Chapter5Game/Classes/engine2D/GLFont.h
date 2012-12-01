//
//  GLFont.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTexture.h"

//alignment flags for use with drawstring:atpoint:withanchor.  yes, these are duped from the j2me javadocs.
#define GRAPHICS_TOP 16
#define GRAPHICS_BOTTOM 32
#define GRAPHICS_VCENTER 2

#define GRAPHICS_LEFT 4
#define GRAPHICS_RIGHT 8
#define GRAPHICS_HCENTER 1

typedef struct {
	unichar character;
	GLfloat tx, ty, tx2, ty2; //texture position and height.
	GLfloat pw, ph; //width and height in pixels.
} Glyph;

@interface GLFont : GLTexture {
	int fontdata_length;
	Glyph* fontdata;
	GLfloat charspacing; //the extra spacing between letters.  will typically be negative, to consume padding.
	float fontheight;
}

- (void) drawString:(NSString*)string atPoint:(CGPoint)point;
- (void) drawString:(NSString*)string atPoint:(CGPoint)point withAnchor:(int) anchor;

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size strokeWidth:(CGFloat)strokeWidth fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor;

@end
