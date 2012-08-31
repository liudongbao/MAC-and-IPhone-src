//
//  GameLayer.h
//  DoodleDrop
//
//  Created by Steffen Itterheim on 11.04.12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer 
{
	CCSprite* player;
}

+(id) scene;

@end
