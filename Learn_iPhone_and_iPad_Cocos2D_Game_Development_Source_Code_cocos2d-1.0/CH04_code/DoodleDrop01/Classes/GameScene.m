//
//  GameScene.m
//  DoodleDrop
//

#import "GameScene.h"

@implementation GameScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	CCLayer* layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		CCSprite* sprite = [CCSprite spriteWithFile:@"Icon.png"];
		sprite.position = CGPointMake(160, 240);
		[self addChild:sprite];
	}

	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	// never forget to call [super dealloc]
	[super dealloc];
}

@end
