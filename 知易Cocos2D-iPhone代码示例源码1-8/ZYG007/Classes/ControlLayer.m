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

		CCSprite *spriteNormal, *spriteSelected;
		CCMenuItemSprite *item_f;
		
		// FIRE
		spriteNormal = [CCSprite spriteWithFile:@"JoyStickMenu.png" rect:CGRectMake((2 + 0) * 11, 0,11,11) ];
		spriteSelected = [CCSprite spriteWithFile:@"JoyStickMenu.png" rect:CGRectMake((2 + 5) * 11, 0,11,11)];
		item_f = [CCMenuItemSprite itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected target:self selector:@selector(OnFire:)];
		
		CCMenu *menu = [CCMenu menuWithItems: item_f, nil];
		
		[menu setPosition:ccp(480 - 11 * 3,  3 + 11 * 2)];
		
		[self addChild: menu];
		mgr.position = menu.position;

		// UP
		item_u_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((0 + 0) * 11,0,11,11)];
		item_u_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((0 + 5) * 11,0,11,11)];
		[item_u_n setPosition:ccp(item_f.position.x, item_f.position.y + 11)];
		[item_u_s setPosition:ccp(item_f.position.x, item_f.position.y + 11)];
		[mgr addChild:item_u_n];
		[mgr addChild:item_u_s];
		[item_u_s setVisible:NO];		
		
		// LEFT
		item_l_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((1 + 0) * 11, 0,11,11)];
		item_l_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((1 + 5) * 11, 0,11,11)];
		[item_l_n setPosition:ccp(item_f.position.x - 11, item_f.position.y)];
		[item_l_s setPosition:ccp(item_f.position.x - 11, item_f.position.y)];
		[mgr addChild:item_l_n];
		[mgr addChild:item_l_s];
		[item_l_s setVisible:NO];	
		
		// RIGHT
		item_r_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((3 + 0) * 11, 0,11,11)];
		item_r_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((3 + 5) * 11, 0,11,11)];
		[item_r_n setPosition:ccp(item_f.position.x + 11, item_f.position.y)];
		[item_r_s setPosition:ccp(item_f.position.x + 11, item_f.position.y)];
		[mgr addChild:item_r_n];
		[mgr addChild:item_r_s];
		[item_r_s setVisible:NO];		
		
		// DOWN
		item_d_n = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((4 + 0) * 11, 0,11,11)];
		item_d_s = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake((4 + 5) * 11, 0,11,11)];
		[item_d_n setPosition:ccp(item_f.position.x, item_f.position.y - 11)];
		[item_d_s setPosition:ccp(item_f.position.x, item_f.position.y - 11)];
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
	[gLayer OnTankAction:kAct];
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
	TankAction lastAct;
	
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

-(void) OnMoveUp: (id) sender
{
	[gLayer OnTankAction:kUp];
/*	
	float x, y, z;
	[[gLayer camera] eyeX:&x eyeY:&y eyeZ:&z];
	[[gLayer camera] setEyeX:x eyeY:y + 20 eyeZ:z];
	
	[[gLayer camera] centerX:&x centerY:&y centerZ:&z];
	[[gLayer camera] setCenterX:x centerY:y + 20 centerZ:z];
*/
}

-(void) OnMoveLeft: (id) sender
{
	[gLayer OnTankAction:kLeft];
/*		
	float x, y, z;
	[[gLayer camera] eyeX:&x eyeY:&y eyeZ:&z];
	[[gLayer camera] setEyeX:x - 20 eyeY:y eyeZ:z];
	
	[[gLayer camera] centerX:&x centerY:&y centerZ:&z];
	[[gLayer camera] setCenterX:x - 20 centerY:y centerZ:z];
*/	
}

-(void) OnMoveDown: (id) sender
{
	[gLayer OnTankAction:kDown];
/*	 
	float x, y, z;
	[[gLayer camera] eyeX:&x eyeY:&y eyeZ:&z];
	[[gLayer camera] setEyeX:x eyeY:y - 20 eyeZ:z];
	
	[[gLayer camera] centerX:&x centerY:&y centerZ:&z];
	[[gLayer camera] setCenterX:x centerY:y - 20 centerZ:z];
*/	
}

-(void) OnMoveRight: (id) sender
{
	[gLayer OnTankAction:kRight];
/*	 
	float x, y, z;
	[[gLayer camera] eyeX:&x eyeY:&y eyeZ:&z];
	[[gLayer camera] setEyeX:x + 20 eyeY:y eyeZ:z];
	
	[[gLayer camera] centerX:&x centerY:&y centerZ:&z];
	[[gLayer camera] setCenterX:x + 20 centerY:y centerZ:z];
*/	
}

-(void) OnFire: (id) sender
{
	[gLayer OnTankAction:kFire];
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
