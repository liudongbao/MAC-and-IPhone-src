//
//  MazeButton.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MazeButton.h"
#import "Sprite.h"
#import "pointmath.h"
#import "ResourceManager.h"

@implementation MazeButton

- (void) press {
	NSString* down[] = {
		@"down",
		@"down-green",
		@"down-red",
	};
	
	sprite.sequence = down[color];
	[g_ResManager playSound:@"tap.caf"];
}

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr color:(int)col {
	[super initWithPos:pos sprite:spr];
	color = col;
	[self press]; //probably should start with up image.  using down for now...
	return self;
}

- (bool) under:(Entity*)other {
	return distsquared(worldPos, other.position) < 32*32;
}

@end
