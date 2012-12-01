//
//  EmuMother.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EmuMother.h"
#import "pointmath.h" //for PI
#import "TileWorld.h" //for TILE_SIZE define

@implementation EmuMother

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr {
	[super initWithPos:pos sprite:spr];
	bounds = CGRectMake(144,687, 192, 64);
	return self;
}

- (void) update:(CGFloat) time {
	nextSpeed = worldSpeed;
	CGPoint revertPos = worldPos;
	[super update:time];
	state_timeout -= time;
	if(worldPos.x < bounds.origin.x ||
		worldPos.x > bounds.origin.x+bounds.size.width ||
		worldPos.y < bounds.origin.y ||
		worldPos.y > bounds.origin.y + bounds.size.height
	){
		//wandered too far.
		worldPos = revertPos;
		state_timeout = 0.0f;
	}
	if(state_timeout <= 0.0f){
		switch (state) {
			case EM_IDLING:
			{
				//pick a random direction for wandering.
				float dir = (random() % 360) / 180.0f * PI;
				float mag = TILE_SIZE*4;
				worldSpeed = PointFromPolarCoord(PolarCoordMake(dir, mag));
				if(fabs(worldSpeed.x) < fabs(worldSpeed.y)){
					//hacks, make primary movement horizontal, because we don't
					//have up/down walk cycles for the emu mother.
					float tmp = worldSpeed.x;
					worldSpeed.x = worldSpeed.y;
					worldSpeed.y = tmp;
				}
				state = EM_WALKING;
				state_timeout = (random() % 1000) / 1000.0f * 1.5f + 0.5f;
			}
			break;
			case EM_WALKING:
				//idle a while.
				worldSpeed = CGPointMake(0,0);
				state = EM_IDLING;
				state_timeout = (random() % 1000) / 1000.0f * 1.5f + 0.5f;
				break;
		}
	}
	switch (state) {
		case EM_IDLING:
			break;
		case EM_WALKING:
			break;
	}
}

@end
