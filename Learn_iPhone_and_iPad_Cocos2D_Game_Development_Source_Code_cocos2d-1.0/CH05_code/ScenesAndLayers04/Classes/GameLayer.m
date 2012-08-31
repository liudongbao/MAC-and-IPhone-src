//
//  GameLayer.m
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 28.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameLayer.h"
#import "MultiLayerScene.h"

@interface GameLayer (PrivateMethods)
-(void) addRandomThings;
@end


@implementation GameLayer

-(id) init
{
	if ((self = [super init]))
	{
		self.isTouchEnabled = YES;

		gameLayerPosition = self.position;

		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite* background = [CCSprite spriteWithFile:@"grass.png"];
		background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		[self addChild:background];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"GameLayer" fontName:@"Marker Felt" fontSize:44];
		label.color = ccBLACK;
		label.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		label.anchorPoint = CGPointMake(0.5f, 1);
		[self addChild:label];
		
		[self addRandomThings];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

// I want the pseudo game objects to move around a bit to illustrate that their movement is always
// relative to the Layer's position.
-(void) runRandomMoveSequence:(CCNode*)node
{
	float duration = CCRANDOM_0_1() * 5 + 1;
	CCMoveBy* move1 = [CCMoveBy actionWithDuration:duration position:CGPointMake(-180, 0)];
	CCMoveBy* move2 = [CCMoveBy actionWithDuration:duration position:CGPointMake(0, -180)];
	CCMoveBy* move3 = [CCMoveBy actionWithDuration:duration position:CGPointMake(180, 0)];
	CCMoveBy* move4 = [CCMoveBy actionWithDuration:duration position:CGPointMake(0, 180)];
	CCSequence* sequence = [CCSequence actions:move1, move2, move3, move4, nil];
	CCRepeatForever* repeat = [CCRepeatForever actionWithAction:sequence];
	[node runAction:repeat];
}

// Faking game objects, they just move around.
-(void) addRandomThings
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	for (int i = 0; i < 4; i++)
	{
		CCSprite* firething = [CCSprite spriteWithFile:@"firething.png"];
		firething.position = CGPointMake(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height);
		[self addChild:firething];
		[self runRandomMoveSequence:firething];
	}

	for (int i = 0; i < 10; i++)
	{
		CCSprite* spider = [CCSprite spriteWithFile:@"spider.png"];
		spider.position = CGPointMake(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height);
		[self addChild:spider];
		[self runRandomMoveSequence:spider];
	}
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	lastTouchLocation = [MultiLayerScene locationFromTouch:touch];
	
	// Stop the move action so it doesn't interfere with the user's scrolling.
	[self stopActionByTag:ActionTagGameLayerMovesBack];
	
	// Always swallow touches, GameLayer is the last layer to receive touches.
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint currentTouchLocation = [MultiLayerScene locationFromTouch:touch];
	
	// Take the difference of the current to the last touch location.
	CGPoint moveTo = ccpSub(lastTouchLocation, currentTouchLocation);
	// Then reverse it since the goal is not to give the impression of moving the camera over the background, 
	// but to touch and move the background.
	moveTo = ccpMult(moveTo, -1);
	
	lastTouchLocation = currentTouchLocation;
	
	// Adjust the layer's position accordingly, this will change the position of all nodes it contains too.
	self.position = ccpAdd(self.position, moveTo);
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	// Move the game layer back to its designated position.
	CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:gameLayerPosition];
	CCEaseIn* ease = [CCEaseIn actionWithAction:move rate:0.5f];
	ease.tag = ActionTagGameLayerMovesBack;
	[self runAction:ease];
}

@end
