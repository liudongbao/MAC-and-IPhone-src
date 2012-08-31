//
//  UserInterfaceLayer.h
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 28.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
	UILayerTagFrameSprite,
	UILayerTagProgressTimer,
} UserInterfaceLayerTags;

@interface UserInterfaceLayer : CCLayer 
{

}

-(BOOL) isTouchForMe:(CGPoint)touchLocation;

@end
