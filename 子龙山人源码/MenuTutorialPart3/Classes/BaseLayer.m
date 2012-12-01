//
//  BaseLayer.m
//  BaseLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "BaseLayer.h"

@implementation BaseLayer
-(id) init{
	self = [super init];
	if(nil == self){
		return nil;
	}
	
	self.isTouchEnabled = YES;
	
	CCSprite *bg = [CCSprite spriteWithFile: @"background.png"];
	bg.position = ccp(160,240);
	[self addChild: bg z:0];
	
	
	return self;
}
@end
