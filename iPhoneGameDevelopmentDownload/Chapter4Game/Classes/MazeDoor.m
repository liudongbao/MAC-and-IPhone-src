//
//  MazeDoor.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MazeDoor.h"
#import "Sprite.h"

@implementation MazeDoor

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr 
{
	[super initWithPos:pos sprite:spr];
	sprite.sequence = @"closed";
	return self;
}

- (void) update:(CGFloat) time {
	[super update:time];
	[sprite update:time];
}
@end
