//
//  Spider.h
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 29.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "cocos2d.h"


@interface Spider : CCNode <CCTargetedTouchDelegate>
{
	// Adding a CCSprite as member variable instead of subclassing from it.
	// This is called composition or aggregation of objects, in contrast to subclassing or inheritance.
	CCSprite* spiderSprite;
	
	int numUpdates;
}

+(id) spiderWithParentNode:(CCNode*)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;

@end
