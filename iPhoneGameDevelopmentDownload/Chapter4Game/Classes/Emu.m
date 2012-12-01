//
//  Emu.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Emu.h"
#import "ResourceManager.h" //for distsquared method.
#import "Sprite.h"
#import "TileWorld.h"
#import "Tile.h"

#import "pointmath.h"

@implementation Emu

@synthesize runawaymode;

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr {
	[super initWithPos:pos sprite:spr];
	worldSpeed = CGPointMake(0,0);
	nextSpeed = CGPointMake(0,0);
	sprite.sequence = @"idle";
	runawaymode = false;
	return self;
}

-(void) flockAgainst:(Emu**) others count:(int)count {

	nextSpeed = scale(worldSpeed, 0.95f);
	
	int neighbor_count=0, vel_count = 0;
	CGPoint avg_pos = CGPointMake(0,0), avg_vel=CGPointMake(0,0);
	collision_tweak = CGPointMake(0,0);
	//short range repulsion, avoid neighbors.
	float nearest_dist=0.0f;
	Emu* nearest_emu;
	for(int i=0;i<count;i++){
		if(self == others[i]) continue;
		float dist = distsquared(worldPos, others[i]->worldPos);
		if(dist < nearest_dist || nearest_dist == 0){
			nearest_dist = dist;
			nearest_emu = others[i];
		}
		if(dist < 64*64) {
			vel_count++;
			avg_vel = add(avg_vel, others[i]->worldSpeed);
		}
		if(dist < 4*4*TILE_SIZE*TILE_SIZE) //having a cutoff for neighbor detection lets us split up groups of emus, and each split group will flock with itself.
		{
			neighbor_count++;
			avg_pos = add(avg_pos, others[i]->worldPos);
		}
	}
	float emuradius = 16.0f;
	if(nearest_dist < emuradius*emuradius) {
		//push away from nearest emu.  not part of flocking... this is collision resolution.
		CGPoint away = toward(nearest_emu->worldPos, worldPos);
		//accel = scale(away, 30.0f);
		float overlap = emuradius - sqrt(nearest_dist);
		collision_tweak = scale(away, overlap*0.25f);
	}

	//attract to average position
	avg_pos = scale(avg_pos, 1.0f/neighbor_count); //make the sum into an actual average.
	CGPoint to = toward(worldPos, avg_pos);
	float dist = sqrt(distsquared(worldPos, avg_pos));
	if(dist > 34 && dist < 128){
		CGPoint accel = scale(to, 1.0f*sqrt(dist-32)); //using a sqrt(distance)/1 relationship here... distance/1 was a bit too exaggerated.
		nextSpeed = add(nextSpeed, accel);
	}
	
	//attract to neighbors' velocity
	if(vel_count > 0){
		if(runawaymode){
			//this one gives interesting behavior, but also adds a constant speed to the entire flock.  would be interesting to toggle this mode on after win condition is met.
			avg_vel = toward(CGPointMake(0, 0), avg_vel); //unitize avg_vel.
			nextSpeed = add(nextSpeed, scale(avg_vel, 5.0f));
		} else {
			avg_vel = scale(avg_vel, 1.0f/vel_count); //average velocity.
			//take weighted average between avg_vel and nextspeed.
			nextSpeed = scale(add(scale(avg_vel, 1.0f), scale(nextSpeed, 10.0f)), 1.0f/11.0f);
		}		
	}

	//worldPos = add(worldPos, collision_tweak); //move this to main update, so we can check collidable tiles.  otherwise we can get stuck in walls.
}

- (void) avoid:(Entity*) other {
	CGPoint away = toward(other->worldPos, worldPos);
	float dist = sqrt(distsquared(other->worldPos, worldPos));
	if(dist < 64){ //vision radius?  
		CGPoint accel = scale(away, 300.0f/dist); //probably want a 1/distance relationship here.
		nextSpeed = add(nextSpeed, accel);
	}
}

- (void) goal:(Entity*) other {
	CGPoint away = toward(other->worldPos, worldPos);
	float dist = sqrt(distsquared(other->worldPos, worldPos));
	if(dist < 30){ //vision radius?  
		CGPoint accel = scale(away, 300.0f/dist); //probably want a 1/distance relationship here.
		nextSpeed = add(nextSpeed, accel);
	}
	if(dist > 34 && dist < 128){
		CGPoint accel = scale(away, -0.5f*(dist-32)); //probably want a distance/1 relationship here.
		nextSpeed = add(nextSpeed, accel);
	}
}

- (void) update:(CGFloat) time{
	CGPoint revertPos = worldPos;
	worldSpeed = nextSpeed;
	worldPos = add(worldPos, scale(worldSpeed, time));
	worldPos = add(worldPos, collision_tweak); //move this to main update, so we can check collidable tiles.
	float dx = -worldSpeed.x, dy = -worldSpeed.y;

	Tile* overtile = [world tileAt:worldPos];
	if(overtile == nil || (overtile->flags & UNWALKABLE) != 0){
		//can't move here.
		worldPos = revertPos;
		//todo: do something to get away from the wall here, otherwise the emu is stuck forever.
		//randomize direction? looks ok... bird might bounce into the fence a few times, but it could pass for a not-so-smart bird.
		float dir = (random() % 360) / 180.0f * PI;
		float mag = TILE_SIZE*2;
		worldSpeed = PointFromPolarCoord(PolarCoordMake(dir, mag));
	}

	if(dx != 0 || dy != 0){
		NSString* facing = nil;
		if(fabs(dx) > fabs(dy)){
			if(dx < 0) {
				facing = @"walkright";
			} else {
				facing = @"walkleft";
			}
		} else {
			if(dy < 0){
				facing = @"walkup";
			} else {
				facing = @"walkdown";
			}
		}
		if(![sprite.sequence isEqualToString:facing])
		{
			//NSLog(@"facing %@", facing);
			sprite.sequence = facing;
		}
	}
	float pixelsmoved = sqrt(dx*dx+dy*dy);
	//using distance-based animation for emus, instead of time-based animation.
	[sprite update:pixelsmoved/1000.0f];
}

@end
