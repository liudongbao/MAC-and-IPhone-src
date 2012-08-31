//
//  HelloWorldLayer.h
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#import "GameKitHelper.h"

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

@class Player;

@interface TileMapLayer : CCLayer <GameKitHelperProtocol>
{
	CGPoint playableAreaMin, playableAreaMax;
	Player* player;

	CGPoint screenCenter;
	CGRect upperLeft, lowerLeft, upperRight, lowerRight;
	CGPoint moveOffsets[MAX_MoveDirections];
	EMoveDirection currentMoveDirection;

	ccTime totalTime;
	int bogusScore;
}

+(CCScene *) scene;

@end
