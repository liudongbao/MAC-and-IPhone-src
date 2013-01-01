//
//  CCFish.m
//  fish
//
//  Created by  on 12-4-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCFish.h"


@implementation CCFish
@synthesize isCatch;

-(Boolean) randomCatch:(int) Level
{
    if (rand()%10>=Level) {
        isCatch = YES;
    }else{
        isCatch = NO;
    }
    return isCatch;
}

-(void) addPath
{
    
    switch(rand()%7)
    {
        case 0:
            [self moveWithParabola:self startP:ccp(1200, 200) endP:ccp(-500, 800) startA:0 endA:20 dirTime:rand()%10+15];
            break;
        case 1:
            [self moveWithParabola:self startP:ccp(-200, 300) endP:ccp(1300, 400) startA:180 endA:170 dirTime:rand()%10+18];
            break;
        case 2:
            [self moveWithParabola:self startP:ccp(-200, 300) endP:ccp(1000, -200) startA:190 endA:200 dirTime:rand()%10+18];
            break;
        case 3:
            [self moveWithParabola:self startP:ccp(1300, 400) endP:ccp(-200, 300) startA:10 endA:5 dirTime:rand()%10+18];
            break;
        case 4:
            [self moveWithParabola:self startP:ccp(400, -1200) endP:ccp(600, 1000) startA:90 endA:93 dirTime:rand()%10+18];
            break;
            
        case 5:
            [self moveWithParabola:self startP:ccp(600, 1000) endP:ccp(400, -200) startA:-70 endA:-80 dirTime:rand()%10+18];
            break;
        case 6:
            [self moveWithParabola:self startP:ccp(1200, 2100) endP:ccp(-200, 300) startA:30 endA:-30 dirTime:rand()%10+18];
            break;
    }
    
};


- (void) moveWithParabola:(CCSprite*)mSprite startP:(CGPoint)startPoint endP:(CGPoint)endPoint startA:(float)startAngle endA:(float)endAngle dirTime:(float)time{ 

    float sx = startPoint.x;
    float sy = startPoint.y; 
    float ex =endPoint.x+rand()%50;
    float ey =endPoint.y+rand()%150; 
    int h = [mSprite contentSize].height*0.5;
    //设置精灵的起始角度
    CGPoint pos = CGPointMake(sx+-200+rand()%400, sy+-200+rand()%400);
    mSprite.position = pos;
    mSprite.rotation=startAngle;
    ccBezierConfig bezier; // 创建贝塞尔曲线
    bezier.controlPoint_1 = ccp(sx, sy); // 起始点
    bezier.controlPoint_2 = ccp(sx+(ex-sx)*0.5, sy+(ey-sy)*0.5+rand()%300); //控制点
    bezier.endPosition = ccp(endPoint.x-30, endPoint.y+h); // 结束位置   
    CCBezierTo *actionMove = [CCBezierTo actionWithDuration:time bezier:bezier]; 
    //创建精灵旋转的动作
    CCRotateTo *actionRotate =[CCRotateTo actionWithDuration:time angle:endAngle];
    //将两个动作封装成一个同时播放进行的动作
    CCActionInterval * action = [CCSpawn actions:actionMove, actionRotate, nil]; 
    CCSequence *sq = [CCSequence actions:action,[CCCallFunc actionWithTarget:self selector:@selector(removeSelf:)],nil];
    [mSprite runAction:sq];
}

-(void) removeSelf:(id)sender
{
    [self removeFromParentAndCleanup:YES];
}
@end
