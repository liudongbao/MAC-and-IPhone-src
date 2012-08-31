//
//  HelloWorldLayer.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TileMapScene.h"
#import "Player.h"

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
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric-with-border.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -500);
		
		self.isTouchEnabled = YES;

		// define the extents of the playable area in tile coordinates
		const int borderSize = 10;
		playableAreaMin = CGPointMake(borderSize, borderSize);
		playableAreaMax = CGPointMake(tileMap.mapSize.width - 1 - borderSize, tileMap.mapSize.height - 1 - borderSize);
		
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		
		// Create the player and add it
		player = [Player player];
		player.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		// approximately position player's texture to best match the tile center position
		player.anchorPoint = CGPointMake(0.3f, 0.1f);
		[self addChild:player];
	}

	return self;
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	float halfMapWidth = tileMap.mapSize.width * 0.5f;
	float mapHeight = tileMap.mapSize.height;
	float tileWidth = tileMap.tileSize.width;
	float tileHeight = tileMap.tileSize.height;
	
	CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
	float mapHeightDiff = mapHeight - tilePosDiv.y;

	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	float posX = (int)(mapHeightDiff + tilePosDiv.x - halfMapWidth);
	float posY = (int)(mapHeightDiff - tilePosDiv.x + halfMapWidth);

	// make sure coordinates are within bounds of the playable area
	posX = MAX(playableAreaMin.x, posX);
	posX = MIN(playableAreaMax.x, posX);
	posY = MAX(playableAreaMin.y, posY);
	posY = MIN(playableAreaMax.y, posY);
	
	pos = CGPointMake(posX, posY);
	
	CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	
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
	
	// internally tile Y coordinates seem to be off by 1, this fixes the returned pixel coordinates
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
	// fix the player's Z position
	[player updateVertexZ:tilePos tileMap:tileMap];
}

#ifdef DEBUG
// Draw the object rectangles for debugging and illustration purposes.
-(void) draw
{
	glLineWidth(2.0f);
	glColor4f(1, 1, 1, 1);

	/*
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;

	// draw each tile's center point as crosshair
	CCTMXLayer* layer1 = [tileMap layerNamed:@"Ground"];
	int width = layer1.layerSize.width;
	int height = layer1.layerSize.height;
	
	for (int x = 0; x < width; x++)
	{
		for (int y = 0; y < height; y++)
		{
			CGPoint tileCoord = CGPointMake(x, y);
			CGPoint tilePos = [layer1 positionAt:tileCoord];
			
			CGPoint center = ccpAdd(tilePos, tileMap.position);
			center = ccpAdd(center, CGPointMake(54 * 0.5f, 49 * 0.25f + 1));
			
			float lineLength = 4;
			CGPoint point1, point2;
			point1 = CGPointMake(center.x - lineLength, center.y);
			point2 = CGPointMake(center.x + lineLength, center.y);
			ccDrawLine(point1, point2);
			point1 = CGPointMake(center.x, center.y - lineLength);
			point2 = CGPointMake(center.x, center.y + lineLength);
			ccDrawLine(point1, point2);
		}
	}
	*/
	
	/*
	// show center screen position
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CGPoint center = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	ccDrawCircle(center, 10, 0, 8, NO);
	 */
	
	/*
	for (int w = 0; w < screenSize.width; w++)
	{
		for (int h = 0; h < screenSize.height; h++)
		{
			CGPoint location = CGPointMake(w, h);
			CGPoint tilePos = [self tilePosFromLocation:location tileMap:tileMap];
			if (tilePos.x < 0 || tilePos.x >= 30 || tilePos.y < 0 || tilePos.y >= 30)
				continue;
			
			glColor4f((int)tilePos.x % 2, (int)tilePos.y % 2, 0.5f, 1);
			ccDrawPoint(location);
		}
	}
	*/
	
	// reset line width & color as to not interfere with draw code in other nodes that draws lines
	glLineWidth(1.0f);
	glColor4f(1, 1, 1, 1);
}
#endif

@end
