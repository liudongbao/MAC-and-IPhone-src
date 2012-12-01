//
//  VectorSprite.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/1/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Sprite.h"

@interface VectorSprite : Sprite {
	CGFloat *points;
	int count;
	CGFloat vectorScale;
}

@property (assign) int count;
@property (assign) CGFloat vectorScale;
@property (assign) CGFloat *points;

+ (VectorSprite *) withPoints: (CGFloat *) rawPoints count: (int) count;
- (void) updateSize;
@end
