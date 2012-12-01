//
//  CompositionActionLayer.m
//  G04
//
//  Created by zhu yi on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CompositionActionLayer.h"
#import "SysMenu.h"

@implementation CompositionActionLayer

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
		[CCMenuItemFont setFontSize:18];
		
		CCMenuItem *SeqMenu = [CCMenuItemFont itemFromString:@"Sequence" target:self selector:@selector(OnSequence:)];
		CCMenuItem *SpwMenu = [CCMenuItemFont itemFromString:@"Spawn" target:self selector:@selector(OnSpawn:)];
		CCMenuItem *RepMenu = [CCMenuItemFont itemFromString:@"Repeat" target:self selector:@selector(OnRepeat:)];
		CCMenuItem *RevMenu = [CCMenuItemFont itemFromString:@"Revers" target:self selector:@selector(OnReverse:)];
		CCMenuItem *AniMenu = [CCMenuItemFont itemFromString:@"Animation" target:self selector:@selector(OnAnimation:)];
		CCMenuItem *RepForMenu = [CCMenuItemFont itemFromString:@"RepeatForever" target:self selector:@selector(OnRepeatForever:)];
		
		CCMenuItem *backMenu = [CCMenuItemFont itemFromString:@"Back" target:self selector:@selector(OnBackMenue:)];
		
		CCMenu *mn = [CCMenu menuWithItems:SeqMenu, SpwMenu, RepMenu, RevMenu, AniMenu, RepForMenu, backMenu, nil];
		
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


- (void) OnAnimation:(id) sender
{
	CCSpriteSheet *mgr = (CCSpriteSheet *)[self getChildByTag:4];

	CCAnimation *animation = [CCAnimation animationWithName:@"flight" delay:0.2f];
	for(int i=0;i<3;i++) {
		int x= i % 3;
		[animation addFrameWithTexture:mgr.texture rect: CGRectMake(x*32, 0, 31, 30) ];
	}		
	
	id action = [CCAnimate actionWithAnimation: animation];
	[sprite runAction:[CCRepeat actionWithAction:action times:10]];		
	
}


- (void) OnSequence:(id) sender
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(s.width/2, 50);
	
	id ac0 = [sprite runAction:[CCPlace actionWithPosition:p]];
	id ac1 = [CCMoveTo actionWithDuration:2 position:ccp(s.width - 50, s.height - 50)];
	id ac2 = [CCJumpTo actionWithDuration:2 position:ccp(150, 50) height:30 jumps:5];
	id ac3 = [CCBlink actionWithDuration:2 blinks:3];
	id ac4 = [CCTintBy actionWithDuration:0.5 red:0 green:255 blue:255];

	
	[sprite runAction:[CCSequence actions:ac0, ac1, ac2, ac3, ac4, ac0, nil]];
		
}

- (void) OnSpawn:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(s.width/2, 50);

	sprite.rotation = 0;
	[sprite setPosition:p];
	
	id ac1 = [CCMoveTo actionWithDuration:2 position:ccp(s.width - 50, s.height - 50)];
	id ac2 = [CCRotateTo actionWithDuration:2 angle:180];
	id ac3 = [CCScaleTo actionWithDuration:1 scale:4];
	id ac4 = [CCScaleBy actionWithDuration:1 scale:0.5];

	id seq = [CCSequence actions:ac3, ac4, nil];

	[sprite runAction:[CCSpawn actions:ac1, ac2, seq, nil]];
	
}

- (void) OnRepeat:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(s.width/2, 50);
	
	sprite.rotation = 0;
	[sprite setPosition:p];
	
	id ac1 = [CCMoveTo actionWithDuration:2 position:ccp(s.width - 50, s.height - 50)];
	id ac2 = [CCJumpBy actionWithDuration:2 position:ccp(-400, -200) height:30 jumps:5];
	id ac3 = [CCJumpBy actionWithDuration:2 position:ccp(s.width/2, 0) height:20 jumps:3];
	
	id seq = [CCSequence actions:ac1, ac2, ac3, nil];
	
	[sprite runAction:[CCRepeat actionWithAction:seq times:3]];	
	
}

- (void) OnReverse:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(s.width/2, 50);
	
	sprite.rotation = 0;
	[sprite setPosition:p];
	
	id ac1 = [CCMoveBy actionWithDuration:2 position:ccp(190, 220)];
	id ac2 = [ac1 reverse];
	
	[sprite runAction:[CCRepeat actionWithAction:[CCSequence actions:ac1, ac2,nil] times:2]];
	
}

- (void) OnRepeatForever:(id) sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint p = ccp(100, 50);
	
	CCSpriteSheet *mgr = (CCSpriteSheet *)[self getChildByTag:4];
	
	CCAnimation *animation = [CCAnimation animationWithName:@"flight" delay:0.1f];
	for(int i=0;i<3;i++) {
		int x= i % 3;
		[animation addFrameWithTexture:mgr.texture rect:CGRectMake(x*32, 0, 31, 30) ];
	}		
	
	id action = [CCAnimate actionWithAnimation: animation];
	
	[sprite runAction:[CCRepeatForever actionWithAction:action]];			
	
	ccBezierConfig bezier;		
	
	sprite.rotation = 0;
	[sprite setPosition:p];
	
	// bezier.startPosition = ccp(0,0);
	bezier.controlPoint_1 = ccp(0, s.height/2);
	bezier.controlPoint_2 = ccp(300, -s.height/2);
	bezier.endPosition = ccp(300,100);
	
	id ac10 = [CCBezierBy actionWithDuration:3 bezier:bezier];
	id ac11 = [CCTintBy actionWithDuration:0.5 red:0 green:255 blue:255];
	
	id ac1 = [CCSpawn actions:ac10, [CCRepeat actionWithAction:ac11 times:4], nil];
	id ac2 = [CCSpawn actions:[ac10 reverse], [CCRepeat actionWithAction:ac11 times:4], nil];
	
	
	[sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:ac1, ac2,nil]]];
	
	/*	
	 id ac2 = [JumpBy actionWithDuration:2 position:ccp(-400, -200) height:30 jumps:5];
	 id ac3 = [JumpBy actionWithDuration:2 position:ccp(s.width/2, 0) height:20 jumps:3];
	 
	 id seq = [Sequence actions:ac1, ac2, ac3, nil];
	 
	 [sprite runAction:[Repeat actionWithAction:seq times:3]];
	 */	
	
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
