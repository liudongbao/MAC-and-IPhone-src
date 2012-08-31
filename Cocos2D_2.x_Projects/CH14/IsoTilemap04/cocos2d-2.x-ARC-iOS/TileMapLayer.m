//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TileMapLayer.h"
#import "AppDelegate.h"
#import "Player.h"
#import "NetworkPackets.h"

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
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		gkHelper.delegate = self;
		[gkHelper authenticateLocalPlayer];
		
		CCTMXTiledMap* tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric-with-border.tmx"];
		[self addChild:tileMap z:-1 tag:TileMapNode];
		
		CCTMXLayer* collisionsLayer = [tileMap layerNamed:@"Collisions"];
		collisionsLayer.visible = NO;

		// Use a negative offset to set the tilemap's start position
		tileMap.position = CGPointMake(-500, -500);
		
		self.isTouchEnabled = YES;
		
		const int borderSize = 10;
		playableAreaMin = CGPointMake(borderSize, borderSize);
		playableAreaMax = CGPointMake(tileMap.mapSize.width - 1 - borderSize,
									  tileMap.mapSize.height - 1 - borderSize);
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		// Create the player and add it
		player = [Player player];
		player.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        // offset player's texture to best match the tile center position
		player.anchorPoint = CGPointMake(0.3f, 0.1f);
		[self addChild:player];
		
		// divide the screen into 4 areas
		screenCenter = CGPointMake(screenSize.width / 2, screenSize.height / 2);
		upperLeft = CGRectMake(0, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerLeft = CGRectMake(0, 0, screenCenter.x, screenCenter.y);
		upperRight = CGRectMake(screenCenter.x, screenCenter.y, screenCenter.x, screenCenter.y);
		lowerRight = CGRectMake(screenCenter.x, 0, screenCenter.x, screenCenter.y);
		
		// to move in any of these directions means to add/subtract 1 to/from the current tile coordinate
		moveOffsets[MoveDirectionNone] = CGPointZero;
		moveOffsets[MoveDirectionUpperLeft] = CGPointMake(-1, 0);
		moveOffsets[MoveDirectionLowerLeft] = CGPointMake(0, 1);
		moveOffsets[MoveDirectionUpperRight] = CGPointMake(0, -1);
		moveOffsets[MoveDirectionLowerRight] = CGPointMake(1, 0);
		
		currentMoveDirection = MoveDirectionNone;
		
		// continuously check for walking
		[self scheduleUpdate];
	}
	return self;
}

-(BOOL) isTilePosBlocked:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	CCTMXLayer* layer = [tileMap layerNamed:@"Collisions"];
	NSAssert(layer != nil, @"Collisions layer not found!");
	
	BOOL isBlocked = NO;
	unsigned int tileGID = [layer tileGIDAt:tilePos];
	if (tileGID > 0)
	{
		NSDictionary* tileProperties = [tileMap propertiesForGID:tileGID];
		id blocks_movement = [tileProperties objectForKey:@"blocks_movement"];
		isBlocked = (blocks_movement != nil);
	}
	
	return isBlocked;
}

-(CGPoint) ensureTilePosIsWithinBounds:(CGPoint)tilePos
{
	// make sure coordinates are within bounds of the playable area
	tilePos.x = MAX(playableAreaMin.x, tilePos.x);
	tilePos.x = MIN(playableAreaMax.x, tilePos.x);
	tilePos.y = MAX(playableAreaMin.y, tilePos.y);
	tilePos.y = MIN(playableAreaMax.y, tilePos.y);
	
	return tilePos;
}

-(CGPoint) floatTilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, tileMap.position);
	
	float halfMapWidth = tileMap.mapSize.width * 0.5f;
	float mapHeight = tileMap.mapSize.height;
	float tileWidth = tileMap.tileSize.width / CC_CONTENT_SCALE_FACTOR();
	float tileHeight = tileMap.tileSize.height / CC_CONTENT_SCALE_FACTOR();
	
	CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
	float mapHeightDiff = mapHeight - tilePosDiv.y;
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	float posX = (mapHeightDiff + tilePosDiv.x - halfMapWidth);
	float posY = (mapHeightDiff - tilePosDiv.x + halfMapWidth);
	
	return CGPointMake(posX, posY);
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
	CGPoint pos = [self floatTilePosFromLocation:location tileMap:tileMap];
	
	// make sure coordinates are within bounds of the playable area, and cast to int
	pos = [self ensureTilePosIsWithinBounds:CGPointMake((int)pos.x, (int)pos.y)];
	
	//CCLOG(@"touch at (%.0f, %.0f) is at tileCoord (%i, %i)", location.x, location.y, (int)pos.x, (int)pos.y);
	
	return pos;
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
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
	// get the position in tile coordinates from the touch location
	CGPoint touchLocation = [self locationFromTouches:touches];
	
	// check on which screen quadrant the touch was and set the move direction accordingly
	if (CGRectContainsPoint(upperLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperLeft;
	}
	else if (CGRectContainsPoint(lowerLeft, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerLeft;
	}
	else if (CGRectContainsPoint(upperRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionUpperRight;
	}
	else if (CGRectContainsPoint(lowerRight, touchLocation))
	{
		currentMoveDirection = MoveDirectionLowerRight;
	}
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	currentMoveDirection = MoveDirectionNone;
}

-(void) update:(ccTime)delta
{
	// Report time-based achievement, simply try to update achievement every second.
	// The first few attempts will fail because the local player hasn't signed in yet. The failed attempts will be cached.
	totalTime += delta;
	if (totalTime > 1.0f)
	{
		totalTime = 0.0f;
		
		NSString* playedTenSeconds = @"PlayedForTenSecs";
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		GKAchievement* achievement = [gkHelper getAchievementByID:playedTenSeconds];
		if (achievement.completed == NO)
		{
			float percent = achievement.percentComplete + 10;
			[gkHelper reportAchievementWithID:playedTenSeconds percentComplete:percent];
		}
	}
	
	CCNode* node = [self getChildByTag:TileMapNode];
	NSAssert([node isKindOfClass:[CCTMXTiledMap class]], @"not a CCTMXTiledMap");
	CCTMXTiledMap* tileMap = (CCTMXTiledMap*)node;
	
	// if the tilemap is currently being moved, wait until it's done moving
	if (tileMap.numberOfRunningActions == 0)
	{
		if (currentMoveDirection != MoveDirectionNone)
		{
			// player is always standing on the tile which is centered on the screen
			CGPoint tilePos = [self tilePosFromLocation:screenCenter tileMap:tileMap];
			
			// get the tile coordinate offset for the direction we're moving to
			NSAssert(currentMoveDirection < MAX_MoveDirections, @"invalid move direction!");
			CGPoint offset = moveOffsets[currentMoveDirection];
			
			// offset the tile position and then make sure it's within bounds of the playable area
			tilePos = CGPointMake(tilePos.x + offset.x, tilePos.y + offset.y);
			tilePos = [self ensureTilePosIsWithinBounds:tilePos];
			
			if ([self isTilePosBlocked:tilePos tileMap:tileMap] == NO)
			{
				// move tilemap so that touched tiles is at center of screen
				[self centerTileMapOnTileCoord:tilePos tileMap:tileMap];

				// update remote devices with the new position
				[self sendPosition:tilePos];
			}
		}
	}
	
	// continuously fix the player's Z position
	CGPoint tilePos = [self floatTilePosFromLocation:screenCenter tileMap:tileMap];
	[player updateVertexZ:tilePos tileMap:tileMap];
	
	// send a score update to remote devices every frame
	[self sendScore];
}


#pragma mark GameKitHelper delegate methods

-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper getLocalPlayerFriends];
	}
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", friends.description);
	
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	
	if (friends.count > 0)
	{
		[gkHelper getPlayerInfo:friends];
	}
	else
	{
		[gkHelper submitScore:1234 category:@"Playtime"];
	}
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	CCLOG(@"onPlayerInfoReceived: %@", players.description);
	
	for (GKPlayer* gkPlayer in players)
	{
		CCLOG(@"PlayerID: %@, Alias: %@, isFriend: %i", gkPlayer.playerID, gkPlayer.alias, gkPlayer.isFriend);
	}
	
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper submitScore:1234 category:@"Playtime"];
}

#pragma mark Leaderboard
-(void) onScoresSubmitted:(BOOL)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
	
	if (success)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper retrieveTopTenAllTimeGlobalScores];
	}
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", scores.description);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showLeaderboard];
}

-(void) showAchievements:(ccTime)delta
{
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showAchievements];
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");

	// add small delay because leaderboard view must be fully moved outside the screen
	// before a new view can be shown
	[self scheduleOnce:@selector(showAchievements:) delay:2.0f];
}

#pragma mark Achievements

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", achievements.description);
}

-(void) onResetAchievements:(BOOL)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) showMatchmaking:(ccTime)delta
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GKMatchRequest* request = [[GKMatchRequest alloc] init];
		request.minPlayers = 2;
		request.maxPlayers = 2;
		
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper showMatchmakerWithRequest:request];
	}
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");

	// add small delay because leaderboard view must be fully moved outside the screen
	// before a new view can be shown
	[self scheduleOnce:@selector(showMatchmaking:) delay:2.0f];
}


// TM16: handles receiving of data, determines packet type and based on that executes certain code
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
	SBasePacket* basePacket = (SBasePacket*)data.bytes;
	CCLOG(@"onReceivedData: %@ fromPlayer: %@ - Packet type: %i", data, playerID, basePacket->type);
	
	switch (basePacket->type)
	{
		case kPacketTypeScore:
		{
			SScorePacket* scorePacket = (SScorePacket*)basePacket;
			CCLOG(@"\tscore = %i", scorePacket->score);
			break;
		}
		case kPacketTypePosition:
		{
			SPositionPacket* positionPacket = (SPositionPacket*)basePacket;
			CCLOG(@"\tposition = (%.1f, %.1f)", positionPacket->position.x, positionPacket->position.y);
			
			// instruct remote players to move their tilemap layer to this position (giving the impression that the player has moved)
			// this is just to show that it's working by "magically" moving the other device's screen/player
			if (playerID != [GKLocalPlayer localPlayer].playerID)
			{
				CCTMXTiledMap* tileMap = (CCTMXTiledMap*)[self getChildByTag:TileMapNode];
				[self centerTileMapOnTileCoord:positionPacket->position tileMap:tileMap];
			}
			break;
		}
		default:
			CCLOG(@"unknown packet type %i", basePacket->type);
			break;
	}
}

// TM16: send a bogus score (simply an integer increased every time it is sent)
-(void) sendScore
{
	if ([GameKitHelper sharedGameKitHelper].currentMatch != nil)
	{
		bogusScore++;
		
		SScorePacket packet;
		packet.type = kPacketTypeScore;
		packet.score = bogusScore;
		
		[[GameKitHelper sharedGameKitHelper] sendDataToAllPlayers:&packet sizeInBytes:sizeof(packet)];
	}
}

// TM16: send a tile coordinate
-(void) sendPosition:(CGPoint)tilePos
{
	if ([GameKitHelper sharedGameKitHelper].currentMatch != nil)
	{
		SPositionPacket packet;
		packet.type = kPacketTypePosition;
		packet.position = tilePos;
		
		[[GameKitHelper sharedGameKitHelper] sendDataToAllPlayers:&packet sizeInBytes:sizeof(packet)];
	}
}


@end
