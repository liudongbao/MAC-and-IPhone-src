//
//  BulletCache.h
//  ShootEmUp
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface BulletCache : CCNode 
{
	CCSpriteBatchNode* batch;
	int nextInactiveBullet;
}

-(void) shootBulletFrom:(CGPoint)startPosition velocity:(CGPoint)velocity frameName:(NSString*)frameName;

@end
