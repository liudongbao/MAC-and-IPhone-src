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
	CCParticleSystem	*emitter;
	CCParticleSystem	*emitter2;
}

+ (id) BulletWithinLayer:(CCLayer *)layer;

- (void)SetGamelayer:(CCLayer *)layer;

- (void)BulletInit;

- (void)FireFrom:(CGPoint)ptFrom To:(CGPoint)ptTo bulletType:(int)bType;


@end
