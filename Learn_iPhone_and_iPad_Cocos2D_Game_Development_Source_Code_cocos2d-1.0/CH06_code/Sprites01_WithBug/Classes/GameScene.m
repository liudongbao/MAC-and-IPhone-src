//
//  GameScene.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"
#import "Ship.h"

@implementation GameScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		Ship* ship = [Ship ship];
		ship.position = CGPointMake([ship texture].contentSize.width / 2, screenSize.height / 2);
		[self addChild:ship];
	}
	return self;
}

-(void) dealloc
{
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
