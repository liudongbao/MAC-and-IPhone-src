//
//  MenuLayer.m
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "MenuLayer.h"

@implementation MenuLayer

-(id) init{
	self = [super init];
		
	CCLabel *titleLeft = [CCLabel labelWithString:@"Menu " fontName:@"Marker Felt" fontSize:48];
	CCLabel *titleRight = [CCLabel labelWithString:@" System" fontName:@"Marker Felt" fontSize:48];
	CCLabel *titleQuotes = [CCLabel labelWithString:@"\"                        \"" fontName:@"Marker Felt" fontSize:48];
	CCLabel *titleCenterTop = [CCLabel labelWithString:@"How to build a..." fontName:@"Marker Felt" fontSize:26];
	CCLabel *titleCenterBottom = [CCLabel labelWithString:@"Part 2" fontName:@"Marker Felt" fontSize:48];
	
	float delayTime = 0.3f;
	
	CCMenuItemImage *startNew = [CCMenuItemImage itemFromNormalImage:@"newGameBtn.png" selectedImage:@"newGameBtn_over.png" target:self selector:@selector(onNewGame:)];

	CCMenuItemImage *credits = [CCMenuItemImage itemFromNormalImage:@"creditsBtn.png" selectedImage:@"creditsBtn_over.png" target:self selector:@selector(onCredits:)];
	
	CCMenu *menu = [CCMenu menuWithItems:startNew, credits, nil];
	
	for (CCMenuItemFont *each in [menu children]) {
		each.scaleX = 0.0f;
		each.scaleY = 0.0f;
		CCAction *action = [CCSequence actions:
							[CCDelayTime actionWithDuration: delayTime],
							[CCScaleTo actionWithDuration:0.5F scale:1.0],
							nil];
		delayTime += 0.2f;
		[each runAction: action];
	}
	
	titleCenterTop.position = ccp(160, 380);
	[self addChild: titleCenterTop];
	
	titleCenterBottom.position = ccp(160, 300);
	[self addChild: titleCenterBottom];
	
	titleQuotes.position = ccp(160, 345);
	[self addChild: titleQuotes];
	
	titleLeft.position = ccp(80, -80);
	CCAction *titleLeftAction = [CCSequence actions:
								 [CCDelayTime actionWithDuration: delayTime],
								 [CCEaseBackOut actionWithAction:
								  [CCMoveTo actionWithDuration: 1.0 position:ccp(80,345)]],
								 nil];
	[self addChild: titleLeft];
	[titleLeft runAction: titleLeftAction];
	
	titleRight.position = ccp(220, 520);
	CCAction *titleRightAction = [CCSequence actions:
								  [CCDelayTime actionWithDuration: delayTime],
								  [CCEaseBackOut actionWithAction:
								   [CCMoveTo actionWithDuration: 1.0 position:ccp(220,345)]],
								  nil];
	[self addChild: titleRight];
	[titleRight runAction: titleRightAction];
	
	menu.position = ccp(160, 200);
	[menu alignItemsVerticallyWithPadding: 40.0f];
	[self addChild:menu z: 2];
	
	return self;
}

- (void)onNewGame:(id)sender{
	[SceneManager goPlay];
}

- (void)onCredits:(id)sender{
	[SceneManager goCredits];
}
@end
