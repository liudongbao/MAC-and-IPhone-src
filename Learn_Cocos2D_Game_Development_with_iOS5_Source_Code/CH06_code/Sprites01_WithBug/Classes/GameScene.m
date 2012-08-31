//
//  GameScene.m
//  SpriteBatches
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
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

@end
