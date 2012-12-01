//
//  Finger.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/11/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface Finger : NSObject {
	int		hash;					// hash from touches
	
	CGFloat x0;						// origin
	CGFloat y0;			
	CGFloat x;						// current
	CGFloat y;
	CGFloat t;						// last time
	CGFloat v;						// last velocity
	CGFloat theta;					// angle
	CGFloat speed;					// speed
	CGFloat accel;
	CGPoint pt;						// last point
}

@property (assign) CGFloat x;
@property (assign) CGFloat y;
@property (assign) CGFloat theta;
@property (assign) CGFloat speed;
@property (assign) CGFloat accel;
@property (assign) CGPoint pt;
@property (assign) int hash;

+ (Finger *) atPoint: (CGPoint) p;
- (void) startAt: (CGPoint) p;
- (void) moveTo: (CGPoint) p;
- (void) update;
- (void) tic: (NSTimeInterval) dt;
- (BOOL) isTouching: (Sprite *) s;

@end
