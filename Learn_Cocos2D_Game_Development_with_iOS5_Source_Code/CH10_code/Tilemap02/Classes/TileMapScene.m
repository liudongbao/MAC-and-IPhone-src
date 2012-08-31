//
//  HelloWorldLayer.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TileMapScene.h"
#import "SimpleAudioEngine.h"

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
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"orthogonal.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		// Use a negative offset to set the tilemap's start position
		//tileMap.position = CGPointMake(-160, -120);

		// hide the event layer, we only need this information for code, not to display it
		CCTMXLayer* eventLayer = [tileMap layerNamed:@"GameEventLayer"];
		eventLayer.visible = NO;

		self.isTouchEnabled = YES;

		[[SimpleAudioEngine sharedEngine] preloadEffect:@"alien-sfx.caf"];
	}

	return self;
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be subtracted, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);

	// scaling tileSize to Retina display size if necessary
	float scaledWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float scaledHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	pos.x = (int)(pos.x / scaledWidth);
	pos.y = (int)((tileMap.mapSize.height * tileMap.tileSize.height - pos.y) / scaledHeight);
	
	CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	NSAssert(pos.x >= 0 && pos.y >= 0 && pos.x < tileMap.mapSize.width && pos.y < tileMap.mapSize.height,
			 @"%@: coordinates (%i, %i) out of bounds!", NSStringFromSelector(_cmd), (int)pos.x, (int)pos.y);
	
	return pos;
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;

	// get the position in tile coordinates from the touch location
	CGPoint touchLocation = [self locationFromTouch:[touches anyObject]];
	CGPoint tilePos = [self tilePosFromLocation:touchLocation tileMap:tileMap];
	
	// Check if the touch was on water (eg. tiles with isWater property drawn in GameEventLayer)
	bool isTouchOnWater = NO;
	CCTMXLayer* eventLayer = [tileMap layerNamed:@"GameEventLayer"];
	int tileGID = [eventLayer tileGIDAt:tilePos];
	
	if (tileGID != 0)
	{
		NSDictionary* properties = [tileMap propertiesForGID:tileGID];
		if (properties)
		{
			CCLOG(@"NSDictionary 'properties' contains:\n%@", properties);
			NSString* isWaterProperty = [properties valueForKey:@"isWater"];
			isTouchOnWater = ([isWaterProperty boolValue] == YES);
		}
	}
	
	// decide what to do depending on where the touch was ...
	if (isTouchOnWater)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
	}
	else
	{
		// get the winter layer and toggle its visibility
		CCTMXLayer* winterLayer = [tileMap layerNamed:@"WinterLayer"];
		winterLayer.visible = !winterLayer.visible;
		
		// remove the touched tile
		//[winterLayer removeTileAt:tilePos];
		
		// adds a given tile
		//tileGID = [winterLayer tileGIDAt:CGPointMake(0, 19)];
		//[winterLayer setTileGID:tileGID at:tilePos];
	}
}

@end
