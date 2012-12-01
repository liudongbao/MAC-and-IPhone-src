//
//  KillingLight.h
//  G05
//
//  Created by zhu yi on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface KillingLight : CCSprite<CCTargetedTouchDelegate> {

}

+ (id)KillingLightWithRect:(CGRect)rect spriteManager:(CCSpriteSheet*)manager;

@end
