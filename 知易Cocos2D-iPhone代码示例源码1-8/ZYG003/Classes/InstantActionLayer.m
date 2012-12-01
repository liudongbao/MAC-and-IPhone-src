//
//  InstantActionLayer.m
//  G04
//
//  Created by Mac Admin on 06/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InstantActionLayer.h"
#import "SysMenu.h"

@implementation InstantActionLayer
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
		
		CCMenuItem *placeMenu = [CCMenuItemFont itemFromString:@"Place" target:self selector:@selector(OnPlaceMenue:)];
		CCMenuItem *hideMenu = [CCMenuItemFont itemFromString:@"Hide" target:self selector:@selector(OnHideMenue:)];
		CCMenuItem *showMenu = [CCMenuItemFont itemFromString:@"Show" target:self selector:@selector(OnShowMenue:)];
		CCMenuItem *toggleMenu = [CCMenuItemFont itemFromString:@"Toggle" target:self selector:@selector(OnToggleMenue:)];
		CCMenuItem *backMenu = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(OnBackMenue:)];
		
		CCMenu *mn = [CCMenu menuWithItems:placeMenu, hideMenu, showMenu, toggleMenu, backMenu, nil];
		
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

- (void) OnPlaceMenue:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(CCRANDOM_0_1() * s.width, CCRANDOM_0_1() * s.height);
	
	[sprite runAction:[CCPlace actionWithPosition:p]];
	
}

- (void) OnHideMenue:(id) sender
{
	[sprite runAction:[CCHide action]];
}

- (void) OnShowMenue:(id) sender
{
	[sprite runAction:[CCShow action]];	
}

- (void) OnToggleMenue:(id) sender
{
	[sprite runAction:[CCToggleVisibility action]];	
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
