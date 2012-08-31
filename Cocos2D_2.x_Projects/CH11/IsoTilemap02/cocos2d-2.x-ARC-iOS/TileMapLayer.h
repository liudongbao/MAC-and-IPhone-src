//
//  HelloWorldLayer.h
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

enum
{
	TileMapNode = 0,
};

@class Player;

@interface TileMapLayer : CCLayer
{
	CGPoint playableAreaMin, playableAreaMax;
	Player* player;
}

+(CCScene *) scene;

@end
