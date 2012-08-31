//
//  HelloWorldLayer.m
//  Tilemap
//
//  Created by Steffen Itterheim on 28.08.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "TileMapLayer.h"
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
	CGPoint touchLocation = [touch locationInView:touch.view];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be subtracted, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	// scaling tileSize to Retina display size
	float pointWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float pointHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	pos.x = (int)(pos.x / pointWidth);
	pos.y = (int)((tileMap.mapSize.height * pointHeight - pos.y) / pointHeight);
	
	CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	if (pos.x < 0 || pos.y < 0 || pos.x >= tileMap.mapSize.width || pos.y >= tileMap.mapSize.height)
	{
		CCLOG(@"%@: coordinates (%i, %i) out of bounds! Adjusting...", NSStringFromSelector(_cmd), (int)pos.x, (int)pos.y);
	}

	pos.x = fmaxf(0, fminf(tileMap.mapSize.width - 1, pos.x));
	pos.y = fmaxf(0, fminf(tileMap.mapSize.height - 1, pos.y));

	return pos;
}

-(CGRect) getRectFromObjectProperties:(NSDictionary*)dict tileMap:(CCTMXTiledMap*)tileMap
{
	float x, y, width, height;
	x = [[dict valueForKey:@"x"] floatValue] + tileMap.position.x;
	y = [[dict valueForKey:@"y"] floatValue] + tileMap.position.y;
	width = [[dict valueForKey:@"width"] floatValue];
	height = [[dict valueForKey:@"height"] floatValue];
	
	return CGRectMake(x, y, width, height);
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	// center tilemap on the given tile pos
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
	
	// tile coordinates are counted from upper left corner, this maps coordinates to lower left corner
	tilePos.y = (tileMap.mapSize.height - 1) - tilePos.y;

	// scaling tileSize to Retina display size
	float pointWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float pointHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();

	// point is now at lower left corner of the screen
	CGPoint scrollPosition = CGPointMake(-(tilePos.x * pointWidth), -(tilePos.y * pointHeight));
	
	// offset point to center of screen and center of tile
	scrollPosition.x += screenCenter.x - pointWidth * 0.5f;
	scrollPosition.y += screenCenter.y - pointHeight * 0.5f;
	
	// make sure tilemap scrolling stops at the tilemap borders
	scrollPosition.x = MIN(scrollPosition.x, 0);
	scrollPosition.x = MAX(scrollPosition.x, -screenSize.width);
	scrollPosition.y = MIN(scrollPosition.y, 0);
	scrollPosition.y = MAX(scrollPosition.y, -screenSize.height);
	
	CCLOG(@"tilePos: (%i, %i) moveTo: (%.0f, %.0f)", 
		  (int)tilePos.x, (int)tilePos.y, scrollPosition.x, scrollPosition.y);
	
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
	CGPoint touchLocation = [self locationFromTouch:touches.anyObject];
	CGPoint tilePos = [self tilePosFromLocation:touchLocation tileMap:tileMap];
	
	// move tilemap so that touched tiles is at center of screen
	[self centerTileMapOnTileCoord:tilePos tileMap:tileMap];

	// Check if the touch was on water (eg. tiles with isWater property drawn in GameEventLayer)
	BOOL isTouchOnWater = NO;
	CCTMXLayer* eventLayer = [tileMap layerNamed:@"GameEventLayer"];
	int tileGID = [eventLayer tileGIDAt:tilePos];
	
	if (tileGID != 0)
	{
		NSDictionary* properties = [tileMap propertiesForGID:tileGID];
		if (properties)
		{
			CCLOG(@"NSDictionary 'properties' contains:\n%@", properties);
			NSString* isWaterProperty = [properties valueForKey:@"isWater"];
			isTouchOnWater = isWaterProperty.boolValue;
		}
	}
	
	// Check if the touch was within one of the rectangle objects
	CCTMXObjectGroup* objectLayer = [tileMap objectGroupNamed:@"ObjectLayer"];
	NSAssert([objectLayer isKindOfClass:[CCTMXObjectGroup class]], 
			 @"ObjectLayer not found or not a CCTMXObjectGroup");
	
	BOOL isTouchInRectangle = NO;
	int numObjects = objectLayer.objects.count;
	for (int i = 0; i < numObjects; i++)
	{
		NSDictionary* properties = [objectLayer.objects objectAtIndex:i];
		CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];
		
		if (CGRectContainsPoint(rect, touchLocation))
		{
			isTouchInRectangle = YES;
			break;
		}
	}
	
	// decide what to do depending on where the touch was ...
	if (isTouchOnWater)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
	}
	else if (isTouchInRectangle)
	{
		CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
		system.autoRemoveOnFinish = YES;
		system.position = touchLocation;
		[self addChild:system z:1];
	}
	else
	{
		// get the winter layer and toggle its visibility
		CCTMXLayer* winterLayer = [tileMap layerNamed:@"WinterLayer"];
		winterLayer.visible = !winterLayer.visible;
		
		// other options you might be interested in are:
		
		// remove the touched tile
		//[winterLayer removeTileAt:tilePos];
		
		// add a specific tile
		//tileGID = [winterLayer tileGIDAt:CGPointMake(0, 19)];
		//[winterLayer setTileGID:tileGID at:tilePos];
	}
}

#ifdef DEBUG
// Draw the object rectangles for debugging and illustration purposes.
-(void) draw
{
	[super draw];
	
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
	
	// get the object layer
	CCTMXObjectGroup* objectLayer = [tileMap objectGroupNamed:@"ObjectLayer"];
	NSAssert([objectLayer isKindOfClass:[CCTMXObjectGroup class]], 
			 @"ObjectLayer not found or not a CCTMXObjectGroup");
	
	// make the lines thicker
	glLineWidth(2.0f * CC_CONTENT_SCALE_FACTOR());
	ccDrawColor4F(1, 0, 1, 1);
	
	int numObjects = objectLayer.objects.count;
	for (int i = 0; i < numObjects; i++)
	{
		NSDictionary* properties = [objectLayer.objects objectAtIndex:i];
		CGRect rect = [self getRectFromObjectProperties:properties tileMap:tileMap];
		
		CGPoint dest = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
		ccDrawRect(rect.origin, dest);
		ccDrawSolidRect(rect.origin, dest, ccc4f(1, 0, 1, 0.3f));
	}
	
	// reset line width & color as to not interfere with draw code in other nodes that draws lines
	glLineWidth(1.0f);
}
#endif
@end
