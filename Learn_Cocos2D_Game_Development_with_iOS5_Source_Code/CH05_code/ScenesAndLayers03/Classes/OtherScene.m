//
//  OtherScene.m
//  ScenesAndLayers
//

#import "OtherScene.h"
#import "FirstScene.h"
#import "LoadingScene.h"


@implementation OtherScene

+(void) simulateLongLoadingTime
{
	// Simulating a long loading time by doing some useless calculation a large number of times. Not exactly rocket science.
	double a = 122, b = 243;
	for (unsigned int i = 0; i < 100000000; i++)
	{
		a = a / b;
	}
}

+(id) scene
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	CCScene* scene = [CCScene node];
	OtherScene* layer = [OtherScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Uses a LoadingScene to hide delay" fontName:@"Arial" fontSize:26];
		label.color = ccYELLOW;
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:label];

		[OtherScene simulateLongLoadingTime];
		
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
	CCScene* newScene = [LoadingScene sceneWithTargetScene:TargetSceneFirstScene];
	[[CCDirector sharedDirector] replaceScene:newScene];
}

// these methods are called when changing scenes
-(void) onEnter
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// must call super here:
	[super onEnter];
}

-(void) onEnterTransitionDidFinish
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	// must call super here:
	[super onEnterTransitionDidFinish];
}

-(void) onExit
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// must call super here:
	[super onExit];
}

@end
