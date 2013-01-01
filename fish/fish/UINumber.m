//
//  UiNumRoll.m
//  WheelScore
//
//  Created by 周海锋 on 12-4-8.
//  Copyright 2012年 CJLU. All rights reserved.
//

#import "UINumber.h"
@implementation UINumber
@synthesize m_texture;

/*
 * init 初始化
 */
-(id) init
{
	if( (self=[super init])) {
        m_texture = NULL;
        m_style = NumStyleNormal;
        m_num = 0;
        m_nPosCur = 0;
        m_nPosEnd = 0;   
        [self setup];
    }
	return self;
}

/*
 * initWithStyle 初始化
 */
-(id) initWithStyle:(NumStyle) style
{
    if( (self=[super init])) 
    {
        m_texture = NULL;
        m_style = style;
        m_num = 0;
        m_nPosCur = 0;
        m_nPosEnd = 0;
        [self setup];
    }
    return self;
}

/*
 * setup 设置texture
 */
-(void)setup
{
    UIImage *image = [UIImage imageNamed:@"number.png"];
    m_texture = [[CCTexture2D alloc]initWithImage:image];
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:m_texture rect:CGRectMake(0, 0, NUM_WIDTH, NUM_HEIGHT)];
    [self setDisplayFrame:frame];
}

/*
 * setNumber 设置显示的数字
 */
-(void) setNumber:(int) num
{
    m_nPosCur = NUM_HEIGHT * m_num;
    m_nPosEnd = NUM_HEIGHT * num;
    if (NumStyleNormal == m_style) {
        m_nMoveLen = 4;
    }
    else if (NumStyleSameTime == m_style) {
        m_nMoveLen = (m_nPosEnd-m_nPosCur)/20;
    }
    
    if (m_num > num) {
        [self schedule:@selector(onRollUP:) interval:0.03];
    }
    else {
        [self schedule:@selector(onRollDown:) interval:0.03];
    }
    m_num = num;
}

/*
 * onRollDown 向下滚动
 */
-(void) onRollDown:(ccTime) dt
{
    m_nPosCur += m_nMoveLen;
    if (m_nPosCur >= m_nPosEnd) {
        m_nPosCur = m_nPosEnd;
        [self unschedule:@selector(onRollDown:)];
    }
    
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:m_texture rect:CGRectMake(0, m_nPosCur, NUM_WIDTH, NUM_HEIGHT)];
    [self setDisplayFrame:frame];
}


/*
 * onRollUP 向上滚动
 */
-(void) onRollUP:(ccTime) dt
{
    m_nPosCur -= 4;
    if (m_nPosCur <= m_nPosEnd) {
        m_nPosCur = m_nPosEnd;
        [self unschedule:@selector(onRollUP:)];
    }
    
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:m_texture rect:CGRectMake(0, m_nPosCur, NUM_WIDTH, NUM_HEIGHT)];
    [self setDisplayFrame:frame];
}

-(void)dealloc
{
    [self unscheduleAllSelectors];
    [m_texture release];
    [super dealloc];
}
@end
