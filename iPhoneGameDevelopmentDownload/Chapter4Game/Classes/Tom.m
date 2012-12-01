//
//  Tom.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tom.h"
#import "TileWorld.h"
#import "Sprite.h"
#import "Rideable.h"
#import "pointmath.h"
#import "ResourceManager.h"

@implementation Tom

@synthesize riding;
@synthesize inJump;
@synthesize celebrating;

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr 
{
	[super initWithPos:pos sprite:spr];
	destPos = worldPos;
	inJump = false;
	last_direction = 2; //down-facing idle.
	celebrating = false;
	dying = false;
	return self;
}

- (void) moveToPosition:(CGPoint) point {
	if(inJump) return; //freeze input while already jumping.
	destPos = point;
	//worldPos = destPos; //warp speed.
}

- (bool) walkable:(CGPoint) point {
	if(inJump) return true;
	if(riding == nil) return [world walkable:point];
	else return [riding under:point];
}

- (void) update:(CGFloat) time {
	float xspeed = 200*time, yspeed=200*time; //pixels per second.
	
	if(dying){
		//you're not a zombie, hold still.
		xspeed = yspeed = 0;
	}
	
	CGPoint revertPos = worldPos;
	
	float dx = worldPos.x - destPos.x;
	if(dx != 0){
		if(fabs(dx) < xspeed){
			worldPos.x = destPos.x;
		} else {
			worldPos.x += -sign(dx)*xspeed;
		}
	}
	
	float dy = worldPos.y - destPos.y;
	if(dy != 0){
		if(fabs(dy) < yspeed){
			worldPos.y = destPos.y;
		} else {
			worldPos.y += -sign(dy)*yspeed;
		}
	}
	
	if(![self walkable:worldPos]){
		if([self walkable:CGPointMake(worldPos.x, revertPos.y)]){
			//just revert y, so we can slide along wall.
			worldPos = CGPointMake(worldPos.x, revertPos.y);
			//if we can't progress any further in x or y, then we are as close to dest as we get.
			if(dx == 0) destPos = worldPos;
		}
		else
			if([self walkable:CGPointMake(revertPos.x, worldPos.y)]){
				//just revert x, so we can slide along wall.
				worldPos = CGPointMake(revertPos.x, worldPos.y);
				//if we can't progress any further in x or y, then we are as close to dest as we get.
				if(dy == 0) destPos = worldPos;
			}
			else {
				//can't move here.
				worldPos = revertPos;
				//so stop trying.
				destPos = worldPos;
			}
	}
	
	if(inJump){
		if([self doneMoving]){
			[riding markRidden:self];
			inJump = false;
		}
	}
	
	NSString* facing = nil;
	int direction = -1;
	if(dx != 0 || dy != 0){
		if(fabs(dx) > fabs(dy)){
			if(dx < 0) {
				direction = 3;
			} else {
				direction = 1;
			}
		} else {
			if(dy < 0){
				direction = 0;
			} else {
				direction = 2;
			}
		}
		last_direction = direction;
	}
		
	if(direction == -1){
		if(celebrating){
			facing = @"celebration";
		} else {
			//idle.
			NSString* idles[] = {
				@"idle-up", @"idle-left", @"idle", @"idle-right"
			};
			facing = idles[last_direction];
		}
	} else {
		if(inJump){
			//directional jump.
			facing = @"jumping";
		} else {
			//directional walk.
			NSString* walks[] = {
				@"walkup", @"walkleft", @"walkdown", @"walkright"
			};
			facing = walks[direction];
		}
	}
	
	if(dying || inJump){
		//let the dying animation proceed as specified in the animation.plist.
	} else {
		if(facing && ![sprite.sequence isEqualToString:facing])
		{
			//NSLog(@"facing %@", facing);
			sprite.sequence = facing;
		}
	}
	
	[sprite update:time];
}

- (bool) doneMoving {
	return worldPos.x == destPos.x && worldPos.y == destPos.y;
}

- (void) doJump {
	inJump = true;
	[g_ResManager playSound:@"tap.caf"];
	if(riding){
		[riding markRidden:nil];
		riding = nil;
	}
	sprite.sequence = @"jump-up";
}

- (void) jump {
	if(inJump) return; //freeze input while already jumping.
	if(dying) return;
	if(![world walkable:worldPos]){
		//search for a walkable tile in the +y direction to jump to.  take the first within 2 tiles.
		for(int i=1;i<=2;i++){
			if([world walkable:CGPointMake(worldPos.x, worldPos.y+i*TILE_SIZE)]){
				[self doJump];
				destPos = CGPointMake(worldPos.x, worldPos.y+i*TILE_SIZE);
				return;
			}
		}
	}
	NSArray* nearby = [world entitiesNear:worldPos withRadius:4*TILE_SIZE];
	for(Rideable* e in nearby){
		//if(e == self) continue; //redundant to Rideable class check, below.
		if(e == riding) continue; //ignore the log we are already on.
		if(![e isKindOfClass:[Rideable class]]) continue; //ignore things we can't ride on.
		CGPoint pos = CGPointMake(worldPos.x, e.position.y-1);
		if(![e under:pos]) {
			//NSLog(@"not lined up to make jump.");
			continue;
		}
		float dy = e.position.y - worldPos.y;
		if(
		   dy > TILE_SIZE*3 //too far to jump
		   || 
		   dy < 0 //ignore logs behind us, only jump forward.
		){
			//NSLog(@"too far to jump");
			continue;
		}
		[self doJump];
		riding = e;
		destPos = pos;
		return;
	}
	NSLog(@"jumper no jumping");
}

//used by Rideable to move the character.
- (void) forceToPos:(CGPoint) pos{
	if([self walkable:pos]){
		worldPos = pos;
		destPos = worldPos;
	}
}

- (void) dieWithAnimation:(NSString*) deathanim {
	if(!dying){ //only die once.
		dying = true;
		sprite.sequence = deathanim;
	}
}

@end
