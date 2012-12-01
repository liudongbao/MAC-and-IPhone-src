//
//  SysMenu.m
//  G03
//
//  Created by Mac Admin on 15/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SysMenu.h"
#import "cocos2d.h"
#import "InstantActionLayer.h"
#import "IntervalActionLayer.h"
#import "CompositionActionLayer.h"
#import "ExtendActionLayer.h"
#import "EaseActionLayer.h"

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
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *sp = [CCSprite spriteWithFile:@"bg.png"];
//		sp.anchorPoint = CGPointZero;
		sp.rotation = 90;
		sp.position = ccp(s.width / 2, s.height / 2);
		

		[self addChild:sp z:0 tag:1];
		
		[CCMenuItemFont setFontName:@"Arial"];
		[CCMenuItemFont setFontSize:25];
		
		CCMenuItem *InsMn = [CCMenuItemFont itemFromString:@"瞬时动作" target:self selector:@selector(OnInstantAction:)];
		CCMenuItem *InvMn = [CCMenuItemFont itemFromString:@"延时动作" target:self selector:@selector(OnIntervalAction:)];
		CCMenuItem *ComMn = [CCMenuItemFont itemFromString:@"组合动作" target:self selector:@selector(OnCompsitionAction:)];
		CCMenuItem *ExtMn = [CCMenuItemFont itemFromString:@"动作扩展" target:self selector:@selector(OnExtendAction:)];
		CCMenuItem *EaseMn = [CCMenuItemFont itemFromString:@"速度变化" target:self selector:@selector(OnEaseAction:)];
		CCMenuItem *quitMn = [CCMenuItemFont itemFromString:@"退出" target:self selector:@selector(onQuit:)];
		
		CCMenu *mn = [CCMenu menuWithItems:InsMn, InvMn, ComMn, EaseMn, ExtMn, quitMn, nil];
		[mn alignItemsVertically];
		
		[self addChild:mn z:1 tag:2];
	
	}
	
	return self;
}

- (void) OnEaseAction:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[EaseActionLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
	
}


- (void) OnExtendAction:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[ExtendActionLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
	
}

- (void) OnInstantAction:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[InstantActionLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
	
}

- (void) OnIntervalAction:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[IntervalActionLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
}


- (void) OnCompsitionAction:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[CompositionActionLayer node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInRTransition transitionWithDuration:1.2f scene:sc]];
	
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
		NSLog(@"YOU CAN'T TERMINATE YOUR APPLICATION PROGRAMATICALLY in SDK 3.0+");
*/
}

- (void) dealloc
{
	[super dealloc];
}
@end
