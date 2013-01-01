//
//  UIRollNum.m
//  WheelScore
//
//  Created by 周海锋 on 12-4-8.
//  Copyright 2012年 CJLU. All rights reserved.
//

#import "UIRollNum.h"
@implementation UIRollNum
@synthesize numArray,m_point,style;

/*
 * init 初始化
 */
-(id) init
{
    if (self = [super init]) {
        m_nNumber = 0;
        m_maxCol = 6;
        numArray =[[NSMutableArray alloc] init];
        zeroFill = YES;
        style = NumStyleNormal;
        [self clearEffect];
    }   
    return self;
}

/*
 * getNumber 获取显示的数字
 */
-(int) getNumber
{
    return m_nNumber;
}

/*
 * setNumber 设置显示的数字
 * num int 设置的数字
 */
-(void) setNumber:(int)num
{
    if (m_nNumber != num) {
        m_nNumber = num;
       [self rebuildEffect];
    }
}

/*
 * rebuildEffect 重新设置每位数字
 */
-(void) rebuildEffect
{
        
    int i=0;
    int num = m_nNumber;
    while (1) {
        if (num<=0) {
            if(m_maxCol<=i && zeroFill)
            break;
        }
        int showNum = num%10;
        
        UINumber* pNumber = [numArray objectAtIndex:i];
        [pNumber setNumber:showNum];
        i++;
        num = num/10;
    }
}

/*
 * rebuildEffect 清楚每位数字
 */
-(void) clearEffect
{
    for(int i=0;i<[numArray count];i++) {
        
        UINumber* pNumber = (UINumber *)[numArray objectAtIndex:i];
        [self removeChild:pNumber cleanup:YES];
    }
    [numArray removeAllObjects];
    
    for (int i=0; i< m_maxCol; i++) {
        UINumber* pNumber = [[UINumber alloc]initWithStyle:style];
        [numArray addObject:pNumber];
        [pNumber setNumber:0];
        [pNumber setPosition:CGPointMake(m_point.x - i*NUM_WIDTH, m_point.y)];
        [pNumber setAnchorPoint:CGPointMake(1, 0.5)];
        [self addChild:pNumber z:100];

    }
}

-(void)dealloc
{
    [numArray release];
     [super dealloc];
}

@end
