//
//  ParallaxLayer.h
//  Parallax01
//
//  Created by Steffen Itterheim on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

typedef enum
{
	ParallaxSceneTagParallaxNode,
	ParallaxSceneTagMotionStreak,
} ParallaxSceneTags;

@interface ParallaxLayer : CCLayer
{
}

+(id) scene;

@end
