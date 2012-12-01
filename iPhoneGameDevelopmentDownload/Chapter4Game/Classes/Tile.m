//
//  Tile.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tile.h"
#import "Sprite.h"
#import "ResourceManager.h"

@implementation Tile

@synthesize textureName;
@synthesize frame;

- (Tile*) init {
	[super init];
	flags = 0;
	return self;
}

- (Tile*) initWithTexture:(NSString*)texture withFrame:(CGRect) _frame
{
	[self init];
	self.textureName = texture;
	self.frame = _frame;
	return self;
}

- (void) drawInRect:(CGRect)rect {
	[[g_ResManager getTexture:textureName] drawInRect:rect withClip:frame withRotation:0];
}

- (void) dealloc {
	[super dealloc];
}

@end
