//
//  ParallaxBackground.h
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 11.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParallaxBackground : CCNode 
{
	CCSpriteBatchNode* spriteBatch;
	float scrollSpeed;
}

@end
