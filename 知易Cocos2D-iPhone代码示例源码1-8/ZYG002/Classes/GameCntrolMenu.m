//
//  GameCntrolMenu.m
//  G03
//
//  Created by zhu yi on 9/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameCntrolMenu.h"
#import "SysMenu.h"

@implementation GameCntrolMenu

- (id) init
{
	self = [super init];
	if (self)
	{

		// Add Control Items
		[CCMenuItemFont setFontSize:22];
		
		CCMenuItem *systemMenu = [CCMenuItemFont itemFromString:@"菜单" target:self selector:@selector(sysMenue:)];
		
		CCMenu *mn = [CCMenu menuWithItems:systemMenu, nil];
		mn.position = ccp(0,0);
		
		systemMenu.anchorPoint = ccp(0, 0);
		systemMenu.position = ccp(0, 0);
		
		[self addChild:mn z:1 tag:2];
	}
	
	return self;
}

- (void) sysMenue:(id) sender
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
