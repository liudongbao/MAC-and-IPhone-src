//
//  TextSprite.m
//  Asteroids
//
//  Created by Scott Penberthy on 3/12/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "TextSprite.h"

@implementation TextSprite
@synthesize text, font, fontSize;

- (id) init
{
	self = [super init];
	if (self) {
		font = [kDefaultFont retain];
		fontSize = kDefaultFontSize;
		text = nil;
		width = height = 0.0;
		charFont = 0;
		charText = 0;
	}
	return self;
}


+ (TextSprite *) withString: (NSString *) label
{
	TextSprite *ts = [[TextSprite alloc] init];
	if (ts) {
		ts.text = [label retain];
	}
	return ts;
}

- (void) newText: (NSString *) val
{
	if (text) [text release];
	text = [val retain];
	width = 0;
	height = 0;
}

- (void) newFont: (NSString *) val
{
	printf("Setting font\n");
	if (font) [font release];
	font = [val retain];
	width = 0;
	height = 0;
}

- (void) computeWidth: (CGContextRef) context
{
	textLength = [text length];
	
	CGFontRef fref = CGFontCreateWithFontName((CFStringRef) font); 
	if (!fref) {
		width=0.0;
		height=0.0;
		printf("Warning: missing font %s\n",charFont);
		return;
	}
	CGRect bbox = CGFontGetFontBBox(fref);
	int units = CGFontGetUnitsPerEm(fref);
	CGPoint left = CGContextGetTextPosition(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextSelectFont(context, [font UTF8String], fontSize, kCGEncodingMacRoman);
	CGContextShowText(context, [text UTF8String], textLength);
	CGPoint right = CGContextGetTextPosition(context);
	width = right.x - left.x;
	height = ( ((float) bbox.size.height) / ((float) units)) * fontSize;
 	
	[self updateBox];
	CGFontRelease(fref);
	
	return;
}

- (void) drawBody: (CGContextRef) context
{
	if (!text) return;
	if (!width) [self computeWidth: context];
	
	CGContextSelectFont(context, [font UTF8String], fontSize, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (context, kCGTextFillStroke);
	CGContextSetRGBFillColor(context, r,g,b,alpha);
	CGContextSetRGBStrokeColor(context,r,g,b,alpha); 
	CGContextShowTextAtPoint(context, 0,0, [text UTF8String], textLength);
}

- (void) moveUpperLeftTo: (CGPoint) p
{
	CGPoint p2 = CGPointMake(0,0);
	
	p2.x = p.x;
	p2.y = p.y + height;
	[self moveTo: p2];
}
	
- (void) dealloc
{
	[text release];
	[font release];
	[super dealloc];
}

@end
