//
//  BulletCache.h
//  ShootEmUp01
//
//  Created by Steffen Itterheim on 05.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BulletCache : CCNode 
{
    CCSpriteBatchNode* batch;
	NSUInteger nextInactiveBullet;
}

-(void) shootBulletFrom:(CGPoint)startPosition 
			   velocity:(CGPoint)velocity 
			  frameName:(NSString*)frameName
		 isPlayerBullet:(BOOL)playerBullet;

-(BOOL) isPlayerBulletCollidingWithRect:(CGRect)rect;
-(BOOL) isEnemyBulletCollidingWithRect:(CGRect)rect;

@end
