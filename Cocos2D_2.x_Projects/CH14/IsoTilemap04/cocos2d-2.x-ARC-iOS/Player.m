//
//  Player.m
//  Tilemap
//
//  Created by Steffen Itterheim on 08.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Player.h"


@implementation Player

+(id) player
{
	return [[self alloc] initWithFile:@"ninja.png"];
}

-(void) updateVertexZ:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// Lowest Z value is at the origin point and its value is equal to map width + height.
	// This is because automatic vertexZ values are not counted along rows or columns of tilemap coordinates,
	// but horizontally (diagonally in tilemap coordinates). Eg the tiles at coordinates:
	// 0,4 / 1,3 / 2,2 / 3,1 / 4,0 all have the same vertexZ value.
	float lowestZ = -(tileMap.mapSize.width + tileMap.mapSize.height);
	
	// Current Z value is simply the sum of the current tile coordinates.
	float currentZ = tilePos.x + tilePos.y;
	
	// Subtract 1 to always make the player appear behind the objects he is positioned at.
	self.vertexZ = lowestZ + currentZ - 1.5f;

	//CCLOG(@"vertexZ: %.3f at tile pos: (%.0f, %.0f) -- lowestZ: %.1f, currentZ: %.0f",
	//	  self.vertexZ, tilePos.x, tilePos.y, lowestZ, currentZ);
}

@end
