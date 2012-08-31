//
//  FirstScene.m
//  ScenesAndLayers
//

#import "FirstScene.h"
#import "OtherScene.h"


@implementation FirstScene

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	CCScene* scene = [CCScene node];
	CCLayer* layer = [FirstScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"First Scene" fontName:@"Marker Felt" fontSize:64];
		label.color = ccGREEN;
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:label];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// PROBLEM: after changing to OtherScene, FirstScene's dealloc is never called due to onExit below
	// missing the call to [super onExit]
	// This leads to FirstScene still reacting to touches, and OtherScene's touch method is not called.
	[[CCDirector sharedDirector] replaceScene:[OtherScene scene]];
}


// PROBLEM: if these two methods are uncommented, Layer won't react to touches at all.
// The reason is the missing call to [super OnEnter(TransitionDidFinish)]
/*
-(void) onEnter
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

-(void) onEnterTransitionDidFinish
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}
*/

// PROBLEM: onExit doesn't call [super onExit], this causes the Layer not to be released from memory.
// The dealloc method of the Layer will then not get called.
-(void) onExit
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

@end
