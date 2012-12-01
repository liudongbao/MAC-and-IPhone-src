//
//  MainScene.m
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"
#import "GameLayer.h"
#import "ControlLayer.h"

@implementation MainScene

+(id) ShowScene
{
	// 'scene' is an autorelease object.
	MainScene *scene = [MainScene node];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{

		// Make all animantion frames for all layer
		
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"enemy.png"];
		
		// manually add frames to the frame cache
		CCSpriteFrame *frame0 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(40*0, 40*0, 40, 40) offset:CGPointZero];
		CCSpriteFrame *frame1 = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(40*1, 40*0, 40, 40) offset:CGPointZero];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame0 name:@"e01"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame1 name:@"e02"];
		
		
		// 'layer' is an autorelease object.
		// ControlLayer *layer = [ControlLayer node];
	
		GameLayer *glayer = [GameLayer node];
		ControlLayer *clayer = [ControlLayer node];
		
		clayer.gLayer = glayer;
		
		// add layer as a child to scene
		[self addChild: glayer];
		[self addChild: clayer];
		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
