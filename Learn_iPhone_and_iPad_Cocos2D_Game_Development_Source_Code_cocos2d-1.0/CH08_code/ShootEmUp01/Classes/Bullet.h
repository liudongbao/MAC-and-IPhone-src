//
//  Bullet.h
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Ship.h"

@interface Bullet : CCSprite 
{
	CGPoint velocity;
}

@property (readwrite, nonatomic) CGPoint velocity;

+(id) bullet;

-(void) shootBulletAt:(CGPoint)startPosition velocity:(CGPoint)vel frameName:(NSString*)frameName;


@end
