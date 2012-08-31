//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC
//
//  Created by Steffen Itterheim on 01.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// declare private methods here to avoid compiler warnings (and potential "undeclared selector" crashes)
@interface HelloWorldLayer (PrivateMethods)
-(void) initSprites;
-(void) performActionSequenceOnNode:(CCNode*)node;
-(void) removeMe:(CCNode*)node;
@end

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init])) {
		glClearColor(0.1f, 0.2f, 0.2f, 1.0f);
		
		// Demonstrates the relative positioning of nodes
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Parent" fontName:@"Marker Felt" fontSize:80];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width * 0.77f, size.height * 0.75f);
		label.color = ccc3(120, 120, 120);
		[self addChild:label];
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Child 1" fontName:@"Marker Felt" fontSize:65];
		label2.color = ccc3(140, 140, 140);
		[label addChild:label2];
		
		CCLabelTTF* label3 = [CCLabelTTF labelWithString:@"Child 2" fontName:@"Marker Felt" fontSize:50];
		label3.color = ccc3(170, 170, 170);
		[label2 addChild:label3];
		
		CCLabelTTF* label4 = [CCLabelTTF labelWithString:@"Child 3" fontName:@"Marker Felt" fontSize:40];
		label4.color = ccc3(210, 210, 210);
		[label3 addChild:label4];
		
		CCLabelTTF* label5 = [CCLabelTTF labelWithString:@"Child 4" fontName:@"Marker Felt" fontSize:30];
		[label4 addChild:label5];
		
		// setup some sprites as children of one another
		[self initSprites];
	}
	return self;
}

-(void) initSprites
{
	// the following sprites are created as children of one another
	// the idea is to show by example how position & rotation behave relative to the parent node
	// but also that not all properties are obeyed by children (unfortunately this affects opacity)
	
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// create the base sprite
	CCSprite* sprite = [CCSprite spriteWithFile:@"Icon.png"];
	sprite.position = CGPointMake(screenSize.width / 4, screenSize.height / 4);
	[self addChild:sprite];
	
	// first child
	CCSprite* child = [CCSprite spriteWithFile:@"Icon.png"];
	child.scale = 0.75f;
	child.position = CGPointMake(-50, 80);
	// the child sprite is added to parentNode
	// note that the z value is -1 and below sprite, this will also cause childOfChild to be drawn below sprite!
	[sprite addChild:child z:-1];
	
	// rotate the child sprite to show how
	// a) the child sprite will be affected when its parent starts rotating
	// b) how its own child sprite is affected and rotates relative to child
	CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:2 angle:360];
	CCRepeatForever* repeat = [CCRepeatForever actionWithAction:rotateBy];
	[child runAction:repeat];
	
	// first child of the child sprite
	CCSprite* childOfChild = [CCSprite spriteWithFile:@"Icon.png"];
	childOfChild.scale = 0.5f;
	childOfChild.position = CGPointMake(125, 50);
	// the childOfChild sprite is added to child
	[child addChild:childOfChild];
	
	// perform the sequence on the sprite
	[self performActionSequenceOnNode:sprite];
}

-(void) performActionSequenceOnNode:(CCNode*)node
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// move with ease (pun intended)
	CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:CGPointMake(screenSize.width * 0.6f, screenSize.height * 0.5f)];
	CCEaseInOut* easeMove = [CCEaseInOut actionWithAction:move rate:3];
	
	// rotate and fade out actions
	// the children rotate relative to the parent and the parent's anchor point
	// however, they don't fade with its parent
	CCRotateBy* rotate = [CCRotateBy actionWithDuration:2 angle:180];
	CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:2];
	
	// call the removeMe method at the end of the sequence
	CCCallFunc* call = [CCCallFuncN actionWithTarget:self selector:@selector(removeMe:)];
	
	// put the sequence together - the list of actions must end with nil!
	CCSequence* sequence = [CCSequence actions:easeMove, rotate, fadeOut, call, nil];
	
	// run the sequence
	[node runAction:sequence];
}

-(void) removeMe:(CCNode*)node
{
	// removes the node from its parent
	[node removeFromParentAndCleanup:YES];
	
	// create a new set of sprites, starting all over again
	[self initSprites];
}

@end
