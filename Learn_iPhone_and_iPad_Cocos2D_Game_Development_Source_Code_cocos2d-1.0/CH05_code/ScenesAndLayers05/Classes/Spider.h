//
//  Spider.h
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 29.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

// Don't forget to #import the cocos2d header when subclassing from NSObject
#import "cocos2d.h"


@interface Spider : NSObject 
{
	// Adding a CCSprite as member variable instead of subclassing from it.
	// This is called composition or aggregation of objects, in contrast to subclassing or inheritance.
	CCSprite* spiderSprite;
	
	int numUpdates;
}

+(id) spiderWithParentNode:(CCNode*)parentNode;
-(id) initWithParentNode:(CCNode*)parentNode;

@end
