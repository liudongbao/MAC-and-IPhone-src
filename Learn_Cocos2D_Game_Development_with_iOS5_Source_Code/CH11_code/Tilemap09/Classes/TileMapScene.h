//
//  HelloWorldLayer.h
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "cocos2d.h"

#import "Player.h"

enum
{
	TileMapNode = 0,
};

typedef enum
{
	MoveDirectionNone = 0,
	MoveDirectionUpperLeft,
	MoveDirectionLowerLeft,
	MoveDirectionUpperRight,
	MoveDirectionLowerRight,
	
	MAX_MoveDirections,
} EMoveDirection;

@interface TileMapLayer : CCLayer
{
	CGPoint playableAreaMin, playableAreaMax;

	Player* player;

	CGPoint screenCenter;
	CGRect upperLeft, lowerLeft, upperRight, lowerRight;
	CGPoint moveOffsets[MAX_MoveDirections];
	EMoveDirection currentMoveDirection;
}

+(id) scene;

@end
