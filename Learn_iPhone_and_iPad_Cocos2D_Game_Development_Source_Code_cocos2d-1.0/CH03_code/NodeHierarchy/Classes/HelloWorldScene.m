//
//  HelloWorldLayer.m
//  NodeHierarchy
//
//  Created by Steffen Itterheim on 12.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"

// declare private methods here to avoid compiler warnings (and potential "undeclared selector" crashes)
@interface HelloWorld (PrivateMethods)
-(void) initSprites;
-(void) performActionSequenceOnNode:(CCNode*)node;
@end


@implementation HelloWorld

+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
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

- (void) dealloc
{
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
