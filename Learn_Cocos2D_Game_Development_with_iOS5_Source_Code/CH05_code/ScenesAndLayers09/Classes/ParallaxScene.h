//
//  ParallaxScene.h
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 30.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	ParallaxSceneTagParallaxNode,
	ParallaxSceneTagRibbon,
} ParallaxSceneTags;

@interface ParallaxScene : CCLayer 
{

}

+(id) scene;

@end
