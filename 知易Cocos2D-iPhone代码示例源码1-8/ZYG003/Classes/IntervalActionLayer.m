//
//  IntervalActionLayer.m
//  G04
//
//  Created by Mac Admin on 07/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IntervalActionLayer.h"
#import "SysMenu.h"

static NSString *actionNames[] = {
		@"MoveTo",
		@"MoveBy",
		@"JumpTo",
		@"JumpBy",
		@"BezierBy",
		@"ScaleTo",
		@"ScaleBy",
		@"RotateTo",
		@"RotateBy",
		@"Blink",
		@"TintTo",
		@"TintBy",
		@"FadeTo",
		@"FadeIn",
		@"FadeOut" };


@implementation IntervalActionLayer

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
		[CCMenuItemFont setFontName:@"Arial"];
		// Add Control Items
		[CCMenuItemFont setFontSize:13];
		

		CCMenuItem *backMenu = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(OnBackMenue:)];
		
		CCMenu *mn = [CCMenu menuWithItems:backMenu, nil];
		
		int actCount = sizeof(actionNames) / sizeof(actionNames[0]) ;
		int i;
		
		for (i = 0; i < actCount; i++) {
			NSString *aName = actionNames[i];
			CCMenuItem *pItm = [CCMenuItemFont itemFromString:aName target:self selector:@selector(OnAction:)];
			[mn addChild:pItm z:1 tag:i];
		}
		
		[mn alignItemsVertically];
		
		//		mn.anchorPoint = ccp(0,1);
		mn.position = ccp(60, mn.position.y);
		
		[self addChild:mn z:1 tag:2];
		
		
		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"flight.png" capacity:5];
		[self addChild:mgr z:0 tag:4];
		
		sprite = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake(32 * 2, 0, 31, 30)];
		[mgr addChild:sprite z:1 tag:5];
		
		sprite.scale = 2.0;
		sprite.position = ccp(s.width/2, 50);
	}
	
	return self;
}

- (void) OnAction:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	int na = [sender tag];
	
	ccBezierConfig bezier;	
	
	switch (na) {
		case 0:
			[sprite runAction:[CCMoveTo actionWithDuration:2 position:ccp(s.width - 50, s.height - 50) ]];
			break;
		case 1:
			[sprite runAction:[CCMoveBy actionWithDuration:2 position:ccp(-50, -50)]];
			break;
		case 2:
			[sprite runAction:[CCJumpTo actionWithDuration:2 position:ccp(150, 50) height:30 jumps:5]];
			break;
		case 3:
			[sprite runAction:[CCJumpBy actionWithDuration:2 position:ccp(100, 100) height:30 jumps:5]];
			break;
		case 4:
			// bezier.startPosition = ccp(0,0);
			bezier.controlPoint_1 = ccp(0, s.height/2);
			bezier.controlPoint_2 = ccp(300, -s.height/2);
			bezier.endPosition = ccp(100,100);
			
			[sprite runAction:[CCBezierBy actionWithDuration:3 bezier:bezier]];
			break;
		case 5:
			[sprite runAction:[CCScaleTo actionWithDuration:2 scale:4]];
			break;
		case 6:
			[sprite runAction:[CCScaleBy actionWithDuration:2 scale:0.5]];
			break;
		case 7:
			[sprite runAction:[CCRotateTo actionWithDuration:2 angle:180]];
			break;
		case 8:
			[sprite runAction:[CCRotateBy actionWithDuration:2 angle:-180]];
			break;
		case 9:
			[sprite runAction:[CCBlink actionWithDuration:3 blinks:5]];
			break;
		case 10:
			[sprite runAction:[CCTintTo actionWithDuration:2 red:255 green:0 blue:0]];
			break;
		case 11:
			[sprite runAction:[CCTintBy actionWithDuration:0.5 red:0 green:255 blue:255]];
			break;
		case 12:
			[sprite runAction:[CCFadeTo actionWithDuration: 1 opacity:80]];
			break;
		case 13:
			[sprite runAction:[CCFadeIn actionWithDuration:1.0f]];
			break;
		case 14:
			[sprite runAction:[CCFadeOut actionWithDuration:1.0f]];
			break;
		default:
			break;
	}
	
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
