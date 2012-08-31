//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TileMapLayer.h"
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

@implementation TileMapLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	TileMapLayer *layer = [TileMapLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -500);
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be subtracted, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	float halfMapWidth = tileMap.mapSize.width * 0.5f;
	float mapHeight = tileMap.mapSize.height;
	float pointWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float pointHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	
	CGPoint tilePosDiv = CGPointMake(pos.x / pointWidth, pos.y / pointHeight);
	float inverseTileY = mapHeight - tilePosDiv.y;
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	float posX = (int)(inverseTileY + tilePosDiv.x - halfMapWidth);
	float posY = (int)(inverseTileY - tilePosDiv.x + halfMapWidth);
	
	// make sure coordinates are within isomap bounds
	posX = MAX(0, posX);
	posX = MIN(tileMap.mapSize.width - 1, posX);
	posY = MAX(0, posY);
	posY = MIN(tileMap.mapSize.height - 1, posY);
	
	pos = CGPointMake(posX, posY);
	
	CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	//CCLOG(@"\tinverseY: %.2f -- tilePosDiv: (%.2f, %.2f) -- halfMapWidth: %.0f\n", inverseTileY, tilePosDiv.x, tilePosDiv.y, halfMapWidth);
	
	return pos;
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// center tilemap on the given tile pos
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	
	// get the ground layer
	CCTMXLayer* layer = [tileMap layerNamed:@"Ground"];
	NSAssert(layer != nil, @"Ground layer not found!");
	
	// internally tile Y coordinates are off by 1, this fixes the returned pixel coordinates
	tilePos.y -= 1;
	
	// get the pixel coordinates for a tile at these coordinates
	CGPoint scrollPosition = [layer positionAt:tilePos];
	// negate the position for scrolling
	scrollPosition = ccpMult(scrollPosition, -1);
	// add offset to screen center
	scrollPosition = ccpAdd(scrollPosition, screenCenter);
	
	CCLOG(@"tilePos: (%i, %i) moveTo: (%.0f, %.0f)", (int)tilePos.x, (int)tilePos.y, scrollPosition.x, scrollPosition.y);
	
	CCAction* move = [CCMoveTo actionWithDuration:0.2f position:scrollPosition];
	[tileMap stopAllActions];
	[tileMap runAction:move];
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView:touch.view];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:touches.anyObject];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
	
	// get the position in tile coordinates from the touch location
	CGPoint touchLocation = [self locationFromTouches:touches];
	CGPoint tilePos = [self tilePosFromLocation:touchLocation tileMap:tileMap];
	
	// move tilemap so that touched tiles is at center of screen
	[self centerTileMapOnTileCoord:tilePos tileMap:tileMap];
}

@end
