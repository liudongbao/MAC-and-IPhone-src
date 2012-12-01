//
//  Croc.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Croc.h"
#import "Sprite.h"
#import "TileWorld.h"

@implementation Croc

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr {
	[super initWithPos:pos sprite:spr];
	bounds = CGRectMake(-59, 0, 123, 28); //croc-specific.  should probably be moved to animation.plist and Animation or Sprite.
	direction = -1; //start off going left, for no good reason.
	sprite.sequence = direction==1?@"idle-flip":@"idle";
	return self;
}

- (bool) under:(CGPoint)point {
	if( 
	   point.x > self.position.x + bounds.origin.x &&
	   point.x < self.position.x + bounds.origin.x + bounds.size.width &&
	   point.y > self.position.y + bounds.origin.y &&
	   point.y < self.position.y + bounds.origin.y + bounds.size.height
	   ) return true;
	return false;
}

- (void) attack:(Entity*) other {
	if([sprite.sequence isEqualToString:@"idle"] || [sprite.sequence isEqualToString:@"idle-flip"]){
		worldPos.x = other.position.x;
		sprite.sequence = direction==1?@"attack-flip":@"attack";
	}
}

- (void) update:(CGFloat) time {
	[super update:time];
	if([sprite.sequence isEqualToString:@"idle"] || [sprite.sequence isEqualToString:@"idle-flip"]){
		//pace back and forth.
		float speed = time*200; //in pixels per second.
		float nextx = speed*direction + worldPos.x;
		if(nextx < 0 || nextx > world.world_width*TILE_SIZE){
			direction = -direction;
			//-1 is @"idle", 1 is @"idle-flip"
			sprite.sequence = direction==1?@"idle-flip":@"idle";
		} else {
			worldPos.x = nextx;
		}
	}
}

@end
