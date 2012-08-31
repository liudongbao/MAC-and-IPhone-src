//
//  HelloWorldLayer.h
//  cocos2d-2.x-Chipmunk-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

#define TILESIZE 32
#define TILESET_COLUMNS 9
#define TILESET_ROWS 19

enum
{
	kTagBatchNode,
};

@interface HelloWorldLayer : CCLayer
{
	CCTexture2D* spriteTexture;
	cpSpace* space;
	cpShape* walls[4];
}

+(CCScene*) scene;
@end
