//
//  ExtendActionLayer.m
//  G04
//
//  Created by Mac Admin on 11/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ExtendActionLayer.h"
#import "SysMenu.h"

@implementation ExtendActionLayer

- (id) init
{
	self = [super init];
	if (self)
	{
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *sp = [CCSprite spriteWithFile:@"Space.png"];
		sp.opacity = 100;
		sp.position = ccp(s.width/2, s.height/2);
		sp.rotation = 90;
		
		[self addChild:sp z:0 tag:1];
		
		// Add action menue
		
		// Add Control Items
		[CCMenuItemFont setFontName:@"Arial"];
		[CCMenuItemFont setFontSize:18];
		
		CCMenuItem *DelMenu = [CCMenuItemFont itemFromString:@"Delay" target:self selector:@selector(OnDelay:)];
		CCMenuItem *CalfMenu = [CCMenuItemFont itemFromString:@"Call func" target:self selector:@selector(OnCallFunc:)];
		CCMenuItem *CalfnMenu = [CCMenuItemFont itemFromString:@"Call func N " target:self selector:@selector(OnCallFuncN:)];
		CCMenuItem *CalfndMenu = [CCMenuItemFont itemFromString:@"Call func N D" target:self selector:@selector(OnCallFuncND:)];
		
		CCMenuItem *backMenu = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(OnBackMenue:)];
		
		CCMenu *mn = [CCMenu menuWithItems:DelMenu, CalfMenu, CalfnMenu, CalfndMenu, backMenu, nil];
		
		[mn alignItemsVertically];
		
		//		mn.anchorPoint = ccp(0,1);
		mn.position = ccp(60, mn.position.y);
		
		[self addChild:mn z:1 tag:2];
		
		
		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"flight.png" capacity:5];
		[self addChild:mgr z:0 tag:4];
		
		sprite = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake(32 * 2,0,31,30)];
		[mgr addChild:sprite z:1 tag:5];
		
		sprite.scale = 2.0;
		sprite.position = ccp(s.width/2, 50);
	}
	
	return self;
}

- (void) OnDelay:(id) sender
{
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(200, 200)];
	id ac2 = [ac1 reverse];
	
	[sprite runAction:[CCSequence actions:ac1, [CCDelayTime actionWithDuration:1], ac2, nil]];		
}

- (void) OnCallFunc:(id) sender
{
	
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(200, 200)];
	id ac2 = [ac1 reverse];

	id acf = [CCCallFunc actionWithTarget:self selector:@selector(CallBack1)];
	
	[sprite runAction:[CCSequence actions:ac1, acf, ac2, nil]];
	
}

- (void) CallBack1
{
	[sprite runAction:[CCTintBy actionWithDuration:0.5 red:255 green:0 blue:255]];	
}

- (void) OnCallFuncN:(id) sender
{
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(200, 200)];
	id ac2 = [ac1 reverse];
	
	id acf = [CCCallFuncN actionWithTarget:self selector:@selector(CallBack2:)];
	
	[sprite runAction:[CCSequence actions:ac1, acf, ac2, nil]];
	
}

- (void) CallBack2:(id)sender
{
	[sender runAction:[CCTintBy actionWithDuration:1 red:255 green:0 blue:255]];	
}

- (void) OnCallFuncND:(id) sender
{
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(200, 200)];
	id ac2 = [ac1 reverse];
	
	id acf = [CCCallFuncND actionWithTarget:self selector:@selector(CallBack3:data:) data:(void*)2];
	
	[sprite runAction:[CCSequence actions:ac1, acf, ac2, nil]];
	
}

-(void) CallBack3:(id)sender data:(void*)data
{
	[sender runAction:[CCTintBy actionWithDuration:(NSInteger)data red:255 green:0 blue:255]];	
}

- (void) OnBackMenue:(id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[SysMenu node]];
	
	[[CCDirector sharedDirector] replaceScene: [CCSlideInLTransition transitionWithDuration:1.2f scene:sc]];
	
}


- (void) dealloc
{
	[super dealloc];
}


@end
