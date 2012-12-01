//
//  GLFont.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLFont.h"


@implementation GLFont

- (void) dealloc
{
	if(fontdata) free(fontdata);
	[super dealloc];
}

- (float) stringWidth:(NSString*)string {
	GLfloat xoff = 0.0f;
	for(int j=0;j<[string length];j++){
		int index=-1;
		unichar ch = [string characterAtIndex:j];
		for(int i=0;i<fontdata_length;i++){
			if(fontdata[i].character == ch){
				index = i;
				break;
			}
		}
		if(index == -1){
			xoff += fontdata[0].pw + charspacing; //insert spaces for characters we don't know about.
			continue;
		}
		Glyph g = fontdata[index];
		xoff += g.pw + charspacing;
	}
	return xoff;
}

- (void) drawString:(NSString*)string atPoint:(CGPoint)point withAnchor:(int) anchor{
	if( (anchor & (GRAPHICS_RIGHT | GRAPHICS_HCENTER)) != 0){ //skip the stringwidth check if possible.
		float w = [self stringWidth:string];
		if( (anchor & GRAPHICS_RIGHT) != 0)
			point.x -= w;
		if( (anchor & GRAPHICS_HCENTER) != 0)
			point.x -= w/2;
	}
	if( (anchor & GRAPHICS_TOP) != 0)
		point.y -= fontheight;
	if( (anchor & GRAPHICS_VCENTER) != 0)
		point.y -= fontheight/2;
	[self drawString:string atPoint:point];
}

//draws align bottom-left, like opengl coordinates.
- (void) drawString:(NSString*)string atPoint:(CGPoint)point {
	if(fontdata == NULL) return;
	glBindTexture(GL_TEXTURE_2D, self.name);
	
	GLfloat xoff = 0.0f;
	for(int j=0;j<[string length];j++){
		int index=-1;
		unichar ch = [string characterAtIndex:j];
		for(int i=0;i<fontdata_length;i++){
			if(fontdata[i].character == ch){
				index = i;
				break;
			}
		}
		if(index == -1){
			xoff += fontdata[0].pw + charspacing; //insert spaces for characters we don't know about.
			continue;
		}
		Glyph g = fontdata[index];
		//todo: it should be faster if we put tex coordinates and vertices inside each Glyph, since they are constant after initialization.
		GLfloat		coordinates[] = { 
			g.tx,	g.ty2,
			g.tx2,	g.ty2,
			g.tx,	g.ty,
			g.tx2,	g.ty 
		};
		GLfloat		width = g.pw,
		height = g.ph;
		GLfloat		vertices[] = {	
			0,	0,	0.0,
			width,	0,	0.0,
			0,	height,	0.0,
			width,	height,	0.0 
		};
		glVertexPointer(3, GL_FLOAT, 0, vertices);
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
		
		glPushMatrix();
		glTranslatef(point.x+xoff, point.y, 0);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		xoff += g.pw + charspacing;
	}
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string fontName:name fontSize:size 
					strokeWidth:0.0f fillColor:[UIColor whiteColor] strokeColor:nil];
//					strokeWidth:0.5f fillColor:[UIColor colorWithRed:1.0f green:0.39f blue:0.0f alpha:1.0f] strokeColor:[UIColor colorWithRed:1.0f green:0.796f blue:0.597f alpha:1.0f]];
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size strokeWidth:(CGFloat)strokeWidth fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor
{
	NSUInteger				width,
	height,
	i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;
	CGSize					dimensions;
	//strokeWidth = 0.5f;
	
	font = [UIFont fontWithName:name size:size];
	charspacing = -strokeWidth - 1; //since we pad the letters out, we need to consume some of that padding when rendering to screen.
	
	Glyph* font_data = malloc(sizeof(Glyph) * [string length]);
	
	float length = 0.0f;
	for(int i=0;i<[string length];i++){
		CGSize size = [[string substringWithRange:NSMakeRange(i, 1)] sizeWithFont:font];
		size.width += strokeWidth*2 + 1; //this should only be +strokewidth, but we get some overlap on character sequences like "kl" with a large strokewidth.  so it's +strokewidth*2.
		size.height += strokeWidth;
		length += size.width;
		dimensions.height = size.height; //this looks wrong.
		font_data[i].character = [string characterAtIndex:i];
		font_data[i].pw = size.width;
		font_data[i].ph = size.height;
	}
	dimensions.width = length;
	
	//expand to power-of-two dimensions.  should probably check for absurdly large widths here.
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
			i *= 2;
		width = i;
	}
	
	fontheight = font.ascender + font.descender;
	
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
			i *= 2;
		height = i;
	}
	
	NSLog(@"allocating font texture, dimensions %dx%d", width, height);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	data = malloc(height * width * 4);
	context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);	
	
	//CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetFillColorWithColor(context, [fillColor CGColor]);
	CGTextDrawingMode drawingMode;
	if(strokeWidth == 0.0f){
		drawingMode = kCGTextFill;
	} else {
		//CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		CGContextSetStrokeColorWithColor(context, [strokeColor CGColor]);
		CGContextSetLineWidth(context, strokeWidth); //this is the stroke width.
		drawingMode = kCGTextFillStroke;
	}
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	CGContextSetTextDrawingMode(context, drawingMode);
	length = 0.0f;
	for(int i=0;i<[string length];i++){
		//CGSize size = [[string substringWithRange:NSMakeRange(i, 1)] sizeWithFont:font];
		CGSize size = CGSizeMake(font_data[i].pw, font_data[i].ph);
		[[string substringWithRange:NSMakeRange(i, 1)] 
		 drawInRect:CGRectMake(length, 0.0f, size.width, size.height) 
		 withFont:font 
		 lineBreakMode:UILineBreakModeClip
		 alignment:UITextAlignmentCenter
		];
		length += size.width;
	}
	//[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kGLTexturePixelFormat_RGBA8888 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	length = 0.0f;
	for(int i=0;i<[string length];i++){
		font_data[i].ty=0;
		font_data[i].tx = length;
		font_data[i].ty2 = self.maxT;
		font_data[i].tx2 = length+font_data[i].pw/self.pixelsWide;
		length = font_data[i].tx2;
	}
	
	if(fontdata) free(fontdata); //just in case initWithString gets called more than once.
	fontdata = font_data;
	fontdata_length = [string length];
	
	return self;
}

@end
