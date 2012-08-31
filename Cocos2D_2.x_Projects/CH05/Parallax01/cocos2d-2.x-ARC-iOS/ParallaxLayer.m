//
//  ParallaxLayer.m
//  Parallax01
//
//  Created by Steffen Itterheim on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ParallaxLayer.h"

@interface ParallaxLayer (PrivateMethods)
-(void) resetMotionStreak;
-(CCMotionStreak*) getMotionStreak;
@end

@implementation ParallaxLayer

+(id) scene
{
	CCScene* scene = [CCScene node];
	ParallaxLayer* layer = [ParallaxLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		// Load the sprites for each parallax layer, from background to foreground.
		CCSprite* para1 = [CCSprite spriteWithFile:@"parallax1.png"];
		CCSprite* para2 = [CCSprite spriteWithFile:@"parallax2.png"];
		CCSprite* para3 = [CCSprite spriteWithFile:@"parallax3.png"];
		CCSprite* para4 = [CCSprite spriteWithFile:@"parallax4.png"];
		
		// Set the correct offsets depending on the screen and image sizes.
		para1.anchorPoint = CGPointMake(0, 1);
		para2.anchorPoint = CGPointMake(0, 1);
		para3.anchorPoint = CGPointMake(0, 0.6f);
		para4.anchorPoint = CGPointMake(0, 0);
		CGPoint topOffset = CGPointMake(0, screenSize.height);
		CGPoint midOffset = CGPointMake(0, screenSize.height / 2);
		CGPoint downOffset = CGPointZero;
		
		// Create a parallax node and add the sprites to it.
		CCParallaxNode* paraNode = [CCParallaxNode node];
		[paraNode addChild:para1 z:1 parallaxRatio:CGPointMake(0.5f, 0) positionOffset:topOffset];
		[paraNode addChild:para2 z:2 parallaxRatio:CGPointMake(1, 0) positionOffset:topOffset];
		[paraNode addChild:para3 z:4 parallaxRatio:CGPointMake(2, 0) positionOffset:midOffset];
		[paraNode addChild:para4 z:3 parallaxRatio:CGPointMake(3, 0) positionOffset:downOffset];
		[self addChild:paraNode z:0 tag:ParallaxSceneTagParallaxNode];
		
		// Move the parallax node to show the parallaxing effect.
		CCMoveBy* move1 = [CCMoveBy actionWithDuration:5 position:CGPointMake(-160, 0)];
		CCMoveBy* move2 = [CCMoveBy actionWithDuration:15 position:CGPointMake(160, 0)];
		CCSequence* sequence = [CCSequence actions:move1, move2, nil];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
		[paraNode runAction:repeat];
		
		
		self.isTouchEnabled = YES;
		[self resetMotionStreak];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

-(void) registerWithTouchDispatcher
{
	[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) resetMotionStreak
{
	// Removes the CCMotionStreak and creates a new one.
	[self removeChildByTag:ParallaxSceneTagMotionStreak cleanup:YES];
	CCMotionStreak* streak = [CCMotionStreak streakWithFade:0.99f 
													 minSeg:8
													  width:32 
													  color:ccc3(255, 0, 255)
											textureFilename:@"spider.png"];
	[self addChild:streak z:5 tag:ParallaxSceneTagMotionStreak];
	
	// changing the blend func can create nice effects
	// try out blend modes with the visual blend func tool: 
	// http://www.andersriggelsen.dk/glblendfunc.php
	streak.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
}

-(CCMotionStreak*) getMotionStreak
{
	CCNode* node = [self getChildByTag:ParallaxSceneTagMotionStreak];
	NSAssert([node isKindOfClass:[CCMotionStreak class]], @"node is not a CCMotionStreak");
	
	return (CCMotionStreak*)node;
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) moveMotionStreakToTouch:(UITouch*)touch
{
	CCMotionStreak* streak = [self getMotionStreak];
	streak.position = [self locationFromTouch:touch];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self moveMotionStreakToTouch:touch];
	
	// Always swallow touches.
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self moveMotionStreakToTouch:touch];
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	//[self resetMotionStreak];
}

@end
