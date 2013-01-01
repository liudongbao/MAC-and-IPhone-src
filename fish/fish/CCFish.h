//
//  CCFish.h
//  fish
//
//  Created by  on 12-4-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum 
{
    FishNoraml = 0,
    FishGold,
    FishShark
}FishType;


@interface CCFish : CCSprite
{
    FishType type;
    bool isCatch;
    CCAction *path;
}
@property (nonatomic,assign) bool isCatch;
-(Boolean) randomCatch:(int) Level;
-(void) addPath;
-(void)moveWithParabola:(CCSprite*)mSprite startP:(CGPoint)startPoint endP:(CGPoint)endPoint startA:(float)startAngle endA:(float)endAngle dirTime:(float)time;
@end
