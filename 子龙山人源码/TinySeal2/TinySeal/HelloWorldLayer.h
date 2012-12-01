//
//  HelloWorldLayer.h
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Terrain.h"

@interface HelloWorldLayer : CCLayer
{
	CCSprite * _background;
    Terrain * _terrain;
}

+(CCScene *) scene;

@end
