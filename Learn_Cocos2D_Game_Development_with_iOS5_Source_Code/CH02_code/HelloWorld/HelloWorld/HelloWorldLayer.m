//
//  HelloWorldLayer.m
//  HelloWorld
//
//  Created by Steffen Itterheim on 12.05.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

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
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]))
	{
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp(size.width / 2, size.height / 2);
		
		// add the label as a child to this Layer
		[self addChild:label];
		
		// our label needs a tag so we can find it later on
		// you can pick any arbitrary number
		label.tag = 13;
		
		// must be enabled if you want to receive touch events!
		self.isTouchEnabled = YES;
	}
	return self;
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

-(void) ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	CCNode* node = [self getChildByTag:13];
	
	// defensive programming: verify the returned node is a CCLabelTTF class object
	NSAssert([node isKindOfClass:[CCLabelTTF class]], @"node is not a CCLabelTTF class!");
	
	CCLabelTTF* label = (CCLabelTTF*)node;
	label.scale = CCRANDOM_0_1();
}

@end
