//
//  UiNumRoll.h
//  WheelScore
//
//  Created by 周海锋 on 12-4-8.
//  Copyright 2012年 CJLU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define NUM_HEIGHT 20
#define NUM_WIDTH  20

typedef enum{
    NumStyleNormal,
    NumStyleSameTime,
}NumStyle;

@interface UINumber : CCSprite {
    NumStyle m_style;       //滚动样式
    int m_num;              //显示的数字
    int m_nPosCur;          //当前的位置
    int m_nPosEnd;          //结束的位置
    int m_nMoveLen;         //每次移动的位置
    CCTexture2D *m_texture; //数字的texture
}

@property(nonatomic,retain) CCTexture2D *m_texture;
-(id) initWithStyle:(NumStyle) style;
-(void) setNumber:(int) num;
-(void) onRollDown:(ccTime) dt;
-(void) onRollUP:(ccTime) dt;
-(void) setup;
@end
