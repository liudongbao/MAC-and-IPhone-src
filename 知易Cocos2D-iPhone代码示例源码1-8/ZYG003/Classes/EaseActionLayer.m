//
//  EaseActionLayer.m
//  G04
//
//  Created by Mac Admin on 12/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EaseActionLayer.h"
#import "SysMenu.h"


static NSString *actionNames[] = {
	@"EaseIn",
	@"EaseOut",
	@"EaseInOut",
	@"EaseSineIn",
	@"EaseSineOut",
	@"EaseSineInOut",
	@"EaseExponentialIn",
	@"EaseExponentialOut",
	@"EaseExponentialInOut",
	@"Speed" };


@implementation EaseActionLayer
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
		[CCMenuItemFont setFontSize:16];
		
		
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
		mn.position = ccp(100, mn.position.y);
		
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

- (void) OnAction:(id) sender
{
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(200, 200)];
	id ac2 = [ac1 reverse];
	id ac = [CCSequence actions:ac1,ac2,nil];
	
	int na = [sender tag];
	switch (na) {
		case 0:
			[sprite runAction:[CCEaseIn actionWithAction:ac rate:3]];
			break;
		case 1:
			[sprite runAction:[CCEaseOut actionWithAction:ac rate:3]];
			break;
		case 2:
			[sprite runAction:[CCEaseInOut actionWithAction:ac rate:3]];
			break;
		case 3:
			[sprite runAction:[CCEaseSineIn actionWithAction:ac]];
			break;
		case 4:
			[sprite runAction:[CCEaseSineOut actionWithAction:ac]];
			break;
		case 5:
			[sprite runAction:[CCEaseSineInOut actionWithAction:ac]];
			break;
		case 6:
			[sprite runAction:[CCEaseExponentialIn actionWithAction:ac]];
			break;
		case 7:
			[sprite runAction:[CCEaseExponentialOut actionWithAction:ac]];
			break;
		case 8:
			[sprite runAction:[CCEaseExponentialInOut actionWithAction:ac]];
			break;
		case 9:
			[sprite runAction:[CCSpeed actionWithAction:ac speed:(CCRANDOM_0_1() * 5)]];
			break;
		default:
			break;
	}
	
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
