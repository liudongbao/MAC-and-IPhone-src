//
//  HelloWorldLayer.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TileMapScene.h"

@implementation TileMapLayer

+(id) scene
{
	CCScene *scene = [CCScene node];
	TileMapLayer *layer = [TileMapLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(1, 1, 0, 1);
		
		NSString* tileMapName = @"isometric.tmx";
		
		// uncomment this line to see a tilemap with incorrect offsets (yellow lines where tiles meet)
		//tileMapName = @"isometric-no-offset.tmx";
		
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:tileMapName];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -300);
		
		self.isTouchEnabled = YES;
	}

	return self;
}

@end
