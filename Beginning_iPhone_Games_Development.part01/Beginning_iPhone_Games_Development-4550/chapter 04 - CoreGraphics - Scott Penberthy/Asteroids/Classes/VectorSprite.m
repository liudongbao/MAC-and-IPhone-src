//
//  VectorSprite.m
//  Asteroids
//
//  Created by Scott Penberthy on 3/1/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "VectorSprite.h"

@implementation VectorSprite

@synthesize count,points,vectorScale;

+ (VectorSprite *) withPoints: (CGFloat *) rawPoints count: (int) count
{
	VectorSprite *v = [[VectorSprite alloc] init];
	v.count = count;
	v.points = rawPoints;
	v.vectorScale = 1.0;
	[v updateSize];
	return v;
}

- (void) scaleTo: (CGFloat) s
{
	self.vectorScale = s;
	self.scale = 1.0;
	[self updateSize];
}

- (void) updateSize
{
	CGFloat w,h,minX,minY,maxX,maxY;
	w = h;
	minX = minY = maxX = maxY = 0.0;
	for (int i=0; i < count; i++) {
		CGFloat x1 = points[i*2]*vectorScale;
		CGFloat y1 = points[i*2+1]*vectorScale;
		if (x1 < minX) minX = x1;
		if (x1 > maxX) maxX = x1;
		if (y1 < minY) minY = y1;
		if (y1 > maxY) maxY = y1;
	}
	width = ceil(maxX - minX);
	height = ceil(maxY - minY);
}

- (void) outlinePath: (CGContextRef) context
{
	CGContextBeginPath(context);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	for (int i=0; i < count; i++) {
		CGFloat x1 = points[i*2]*vectorScale;
		CGFloat y1 = points[i*2+1]*vectorScale;
		if (i == 0) {
			CGContextMoveToPoint(context, x1, y1);
		}
		else {
			CGContextAddLineToPoint(context, x1, y1);
		}
	}
	
	CGContextClosePath(context);
}

- (void) drawBody:(CGContextRef)context 
{
	[self outlinePath: context];
	CGContextDrawPath(context,kCGPathFillStroke);
	
	[self outlinePath: context];
	CGContextClip(context);
	[self gradientFill: context];

}


@end
