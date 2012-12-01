//
//  BulletSprite.h
//  T06
//
//  Created by ZhuYi on 10/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BulletSprite : CCSprite {
	CCLayer *gLayer;
}

+ (id) BulletWithinLayer:(CCLayer *)layer;

- (void)SetGamelayer:(CCLayer *)layer;



@end
