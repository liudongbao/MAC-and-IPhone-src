//
//  ControlLayer.h
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"

@interface ControlLayer : CCLayer {
	
	GameLayer *gLayer;

	// action button
	CCSprite *item_u_n, *item_u_s, *item_l_n, *item_l_s, *item_r_n, *item_r_s, *item_d_n, *item_d_s;
	
	// action state
	TankAction kAct;
	
}

@property (nonatomic,readwrite,assign) GameLayer *gLayer;


- (void)KeepDoing;

@end
