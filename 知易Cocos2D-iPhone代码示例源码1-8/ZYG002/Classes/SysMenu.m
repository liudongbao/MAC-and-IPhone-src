//
//  SysMenu.m
//  G03
//
//  Created by Mac Admin on 15/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SysMenu.h"
#import "cocos2d.h"
#import "GameLayer.h"
#import "SettingsLayer.h"
#import "GameCntrolMenu.h"


@implementation SysMenu

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SysMenu *layer = [SysMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		CCSprite *sp = [CCSprite spriteWithFile:@"bg.png"];
		sp.anchorPoint = CGPointZero;

		[self addChild:sp z:0 tag:1];
		
//		[MenuItemFont setFontName:@"Marker Felt"];
		[CCMenuItemFont setFontSize:25];
		
		CCMenuItem *newGame = [CCMenuItemFont itemFromString:@"新游戏" target:self selector:@selector(newGame:)];
		CCMenuItem *loadGame = [CCMenuItemFont itemFromString:@"旧的回忆" target:self selector:nil];
		CCMenuItem *GameSttings = [CCMenuItemFont itemFromString:@"设置" target:self selector:@selector(OnSettings:)];
		CCMenuItem *helpGame = [CCMenuItemFont itemFromString:@"帮助" target:self selector:nil];
		CCMenuItem *quitGame = [CCMenuItemFont itemFromString:@"退出" target:self selector:@selector(onQuit:)];
		
		CCMenu *mn = [CCMenu menuWithItems:newGame, loadGame, GameSttings, helpGame, quitGame, nil];
		[mn alignItemsVertically];
		
		[self addChild:mn z:1 tag:2];
	
	}
	
	return self;
}


- (void) newGame:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[GameLayer node]];
	[sc addChild:[GameCntrolMenu node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
	
}

- (void) OnSettings:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[SettingsLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCShrinkGrowTransition transitionWithDuration:1.2f scene:sc]];
	
}

-(void) onQuit: (id) sender
{
/*
	[[CCDirector sharedDirector] end];
	
	// HA HA... no more terminate on sdk v3.0
	// http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html
	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
	else
		CCLOG(@"YOU CAN'T TERMINATE YOUR APPLICATION PROGRAMATICALLY in SDK 3.0+");
*/
}

- (void) dealloc
{
	[super dealloc];
}
@end
