//
//  ControlLayer.m
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ControlLayer.h"


@implementation ControlLayer

@synthesize gLayer;

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"JoyStickMenu.png"];
		[self addChild:mgr];
		
		
		// FIRE
/*
		spriteNormal = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((2 + 0) * 11, 0,11,11)];
		spriteSelected = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((2 + 5) * 11, 0,11,11)];
		[mgr addChild:spriteNormal];
		[mgr addChild:spriteSelected];
		item_f = [MenuItemAtlasSprite itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected target:self selector:nil];
		
		Menu *menu = [Menu menuWithItems: item_f, nil];
		
		[menu setPosition:ccp(480 - 11 * 3,  3 + 11 * 2)];
		
		[self addChild: menu];
		mgr.position = menu.position;
*/
		
		item_f_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((2 + 0) * 11,0,11,11)];
		item_f_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((2 + 5) * 11,0,11,11)];
		[mgr addChild:item_f_n];
		[mgr addChild:item_f_s];
		[item_f_s setVisible:NO];		
		
		[item_f_n setPosition:ccp(480 - 11 * 3,  3 + 11 * 2)];
		//mgr.position = item_f_n.position;
		
		
		// UP
		item_u_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((0 + 0) * 11,0,11,11)];
		item_u_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((0 + 5) * 11,0,11,11)];
		[item_u_n setPosition:ccp(item_f_n.position.x, item_f_n.position.y + 11)];
		[item_u_s setPosition:ccp(item_f_n.position.x, item_f_n.position.y + 11)];
		[mgr addChild:item_u_n];
		[mgr addChild:item_u_s];
		[item_u_s setVisible:NO];		
		
		// LEFT
		item_l_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((1 + 0) * 11, 0,11,11)];
		item_l_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((1 + 5) * 11, 0,11,11)];
		[item_l_n setPosition:ccp(item_f_n.position.x - 11, item_f_n.position.y)];
		[item_l_s setPosition:ccp(item_f_n.position.x - 11, item_f_n.position.y)];
		[mgr addChild:item_l_n];
		[mgr addChild:item_l_s];
		[item_l_s setVisible:NO];	
		
		// RIGHT
		item_r_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((3 + 0) * 11, 0,11,11)];
		item_r_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((3 + 5) * 11, 0,11,11)];
		[item_r_n setPosition:ccp(item_f_n.position.x + 11, item_f_n.position.y)];
		[item_r_s setPosition:ccp(item_f_n.position.x + 11, item_f_n.position.y)];
		[mgr addChild:item_r_n];
		[mgr addChild:item_r_s];
		[item_r_s setVisible:NO];		
		
		// DOWN
		item_d_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((4 + 0) * 11, 0,11,11)];
		item_d_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((4 + 5) * 11, 0,11,11)];
		[item_d_n setPosition:ccp(item_f_n.position.x, item_f_n.position.y - 11)];
		[item_d_s setPosition:ccp(item_f_n.position.x, item_f_n.position.y - 11)];
		[mgr addChild:item_d_n];
		[mgr addChild:item_d_s];
		[item_d_s setVisible:NO];		
		
		// Enable touch
		[self setIsTouchEnabled:YES];
		
		
	}
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(CGRect)AtlasRect:(CCSprite *)atlSpr
{
	CGRect rc = [atlSpr textureRect];
	return CGRectMake( - rc.size.width / 2, -rc.size.height / 2, rc.size.width, rc.size.height);	
}

- (void) KeepDoing;
{
	[gLayer OnMapAction:kAct];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint local;
	CGRect r;
	
	local = [item_u_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_u_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_u_n setVisible:NO];
		[item_u_s setVisible:YES];	
		kAct = kUp;
		[self schedule:@selector(KeepDoing) interval: 1/30];
		
		return YES;
	}

	local = [item_l_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_l_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_l_n setVisible:NO];
		[item_l_s setVisible:YES];		
		kAct = kLeft;
		[self schedule:@selector(KeepDoing) interval: 1/30];

		return YES;
	}
	
	local = [item_r_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_r_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_r_n setVisible:NO];
		[item_r_s setVisible:YES];
		kAct = kRight;
		[self schedule:@selector(KeepDoing) interval: 1/30];
		
		return YES;
	}
	
	local = [item_d_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_d_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_d_n setVisible:NO];
		[item_d_s setVisible:YES];	
		kAct = kDown;
		[self schedule:@selector(KeepDoing) interval: 1/30];
		
		return YES;
	}
	
	return NO;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint local;
	CGRect r;
	bool bHit;
	MapAction lastAct;
	
	bHit = NO;
	lastAct = kAct;
	
	local = [item_u_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_u_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_u_n setVisible:NO];
		[item_u_s setVisible:YES];	
		kAct = kUp;
		bHit = YES;
	}
	
	local = [item_l_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_l_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_l_n setVisible:NO];
		[item_l_s setVisible:YES];		
		kAct = kLeft;
		bHit = YES;
	}
	
	local = [item_r_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_r_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_r_n setVisible:NO];
		[item_r_s setVisible:YES];
		kAct = kRight;
		bHit = YES;
	}
	
	local = [item_d_n convertTouchToNodeSpaceAR:touch];
	r = [self AtlasRect:item_d_n];	
	if( CGRectContainsPoint( r, local))
	{
		[item_d_n setVisible:NO];
		[item_d_s setVisible:YES];	
		kAct = kDown;
		bHit = YES;
	}	

	if (! bHit)
	{
		[self unschedule:@selector(KeepDoing)];
		
		[item_u_n setVisible:YES];
		[item_u_s setVisible:NO];		
		
		[item_l_n setVisible:YES];
		[item_l_s setVisible:NO];		
		
		[item_r_n setVisible:YES];
		[item_r_s setVisible:NO];		
		
		[item_d_n setVisible:YES];
		[item_d_s setVisible:NO];		
		
		[item_d_n setVisible:YES];
		[item_d_s setVisible:NO];	
		
		kAct = kStay;
	}
	else
	{
		if (lastAct != kAct)
		{
			[self schedule:@selector(KeepDoing) interval: 1/30];
		}
	}

}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	[self unschedule:@selector(KeepDoing)];
	
	[item_u_n setVisible:YES];
	[item_u_s setVisible:NO];		

	[item_l_n setVisible:YES];
	[item_l_s setVisible:NO];		

	[item_r_n setVisible:YES];
	[item_r_s setVisible:NO];		

	[item_d_n setVisible:YES];
	[item_d_s setVisible:NO];		
	
	[item_d_n setVisible:YES];
	[item_d_s setVisible:NO];	
	
	kAct = kStay;

}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
