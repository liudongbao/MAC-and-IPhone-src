//
//  Sprite.h
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Defs.h"

@interface Sprite : NSObject {
	uint type;						// type of our sprite
	
	CGFloat x;						// x location
	CGFloat y;						// y location
	CGFloat r;						// red tint
	CGFloat g;						// green tint
	CGFloat b;						// blue tint
	CGFloat alpha;					// alpha value, for transparency
	CGFloat speed;					// speed of movement in pixels/frame
	CGFloat angle;					// angle of movement in degrees
	CGFloat rotation;				// rotation of our sprite in degrees, about the center
	CGFloat width;					// width of sprite in pixels
	CGFloat height;					// height of sprite in pixels
	CGFloat scale;					// uniform scaling factor for size
	int frame;						// from 0 to (rows*cols - 1)
	
	CGFloat cosTheta;				// pre-computed for speed
	CGFloat sinTheta;
	CGRect box;						// our bounding box
	
	BOOL render;					// true when we're rendering
	BOOL offScreen;					// true when we're off the screen
	BOOL wrap;						// true if you want the motion to wrap on the screen
}

@property (assign) BOOL wrap, render, offScreen;
@property (assign) CGFloat x, y, r, g, b, alpha;
@property (assign) CGFloat speed, angle, rotation;
@property (assign) CGFloat width, height, scale;
@property (assign) CGRect box;
@property (assign) int frame;
@property (assign) uint type;

- (BOOL) hitTest: (CGRect) rect;
- (BOOL) spriteHitTest: (Sprite *) s;
- (void) updateBox;
- (void) moveTo: (CGPoint) p;
- (void) scaleTo: (CGFloat) s;
- (void) draw: (CGContextRef) context;
- (void) outlinePath: (CGContextRef) context;
- (void) drawBody: (CGContextRef) context;
- (void) tic: (NSTimeInterval) dt;
- (void) gradientFill: (CGContextRef) myContext;
- (void) applyForce: (CGFloat) magnitude atAngle: (CGFloat) degrees;
- (BOOL) lineHitTest: (CGPoint) p0 p1: (CGPoint) p1;

@end
