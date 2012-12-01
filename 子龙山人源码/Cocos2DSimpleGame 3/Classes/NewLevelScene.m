//
//  NewLevelScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 3/22/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "NewLevelScene.h"
#import "HelloWorldScene.h"
#import "Cocos2DSimpleGameAppDelegate.h"

@implementation NewLevelScene
@synthesize layer = _layer;

- (id)init {
    
	if ((self = [super init])) {
		self.layer = [NewLevelLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation NewLevelLayer

- (void)reset {
    [self runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:3],
                     [CCCallFunc actionWithTarget:self selector:@selector(newLevelDone)],
                     nil]];
}

-(id) init
{
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Get Ready!!" fontName:@"Arial" fontSize:32];
		label.color = ccc3(0,0,0);
		label.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:label];
		
	}	
	return self;
}

- (void)newLevelDone {
    
    Cocos2DSimpleGameAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate nextLevel];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
