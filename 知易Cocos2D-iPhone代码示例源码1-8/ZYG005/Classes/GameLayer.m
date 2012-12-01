//
//  GameLayer.m
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameLayer

@synthesize mapX;
@synthesize mapY;
@synthesize screenWidth;
@synthesize screenHeight;
@synthesize tileSize;
@synthesize gameWorld;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		// Load level map
		gameWorld = [CCTMXTiledMap tiledMapWithTMXFile:@"Level1.tmx"];
		[self addChild:gameWorld z:0 tag:9];
		
		// explode1 
		SheetExplode = [CCSpriteSheet spriteSheetWithFile:@"Explode1.png" capacity:10];
		[gameWorld addChild:SheetExplode z:99];
		
		spriteExplode = [CCSprite spriteWithTexture:SheetExplode.texture rect:CGRectMake(0,0,23,23)];
		[SheetExplode addChild:spriteExplode z:1 tag:5];

		spriteExplode.position = ccp(240, 160);
		[spriteExplode setVisible:NO];
		
		// Enable touch
		[self setIsTouchEnabled:YES];
		
		// Get origenal OpenGL ES view point
		[[self camera] eyeX:&viewOrgX eyeY:&viewOrgY eyeZ:&viewOrgZ];
		
		// init param
		CGSize size = [[CCDirector sharedDirector] winSize];
		screenWidth = size.width;
		screenHeight = size.height;
		
		tileSize = gameWorld.tileSize.width;
		
		mapX = 0;
		mapY = 0;
	
	}
	return self;
}

-(void) onExit
{
}

-(unsigned int)TiltIDFromPosition:(CGPoint)pos
{
	CGPoint cpt = [self tileCoordinateFromPos:pos];
	CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
	return [ly tileGIDAt:cpt];
}

-(void) DestpryTile:(CGPoint)pos
{
	CGPoint cpt = [self tileCoordinateFromPos:pos];
	CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
	[ly setTileGID:4 at:cpt];
	
}

-(void) ShowExplodeAt:(CGPoint) posAt
{
	int nSize;
//	CCSpriteSheet *mgr = (CCSpriteSheet *)[gameWorld getChildByTag:99];
	
	nSize = 23;
	
	[spriteExplode setPosition:posAt];
	[spriteExplode setVisible:YES];

	CCAnimation *animation = [CCAnimation animationWithName:@"exp" delay:0.1f];
	for(int i=0;i<8;i++) {
		[animation addFrameWithTexture:SheetExplode.texture rect:CGRectMake(i*nSize, 0, nSize, nSize) ];
	}				
	
	id action = [CCAnimate actionWithAnimation: animation];
	id ac = [CCSequence actions: action, [CCHide action], nil];
	
	[spriteExplode runAction:ac];	
	
}

-(CGPoint)tileCoordinateFromPos:(CGPoint)pos
{
	int cox, coy;

	CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
	
	if (ly == nil)
	{
		CCLOG(@"ERROR: Layer not found!");
		return ccp(-1, -1);
	}
	
	CGSize szLayer = [ly layerSize];
	CGSize szTile = [gameWorld tileSize];
	
	cox = pos.x / szTile.width;
	coy = szLayer.height - pos.y / szTile.height;
	
	if ((cox >= 0) && (cox < szLayer.width) && (coy >= 0) && (coy < szLayer.height))
	{
		return ccp(cox, coy);
	}
	else {
		return ccp(-1, -1);
	}
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	touchPoint.x = touchPoint.x - mapX;
	touchPoint.y = touchPoint.y - mapY;
	
	CGPoint cpt = [self tileCoordinateFromPos:touchPoint];
	if (cpt.x != -1)
	{
		CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
		unsigned int tid;
		
		tid = [ly tileGIDAt:cpt];
		
		CCLOG([NSString stringWithFormat:@"x=%.2f, y=%.2f, id = %x", cpt.x, cpt.y, tid]);

		if (tid != 1)
			[self ShowExplodeAt:CGPointMake(touchPoint.x, touchPoint.y)];
		
		if (tid == 2)
			[ly setTileGID:5 at:cpt];
			
		if (tid == 4)
			[ly setTileGID:6 at:cpt];
		
		if (tid == 5)
			[ly setTileGID:4 at:cpt];		

		if (tid == 6)
			[ly setTileGID:1 at:cpt];		
		
/*		
		AtlasSprite *pTile = [ly tileAt:cpt];
	
		[pTile runAction:[Blink actionWithDuration:2 blinks:3]];
*/
		
	}
	else {
		NSLog(@"No tile there!");
	}
}

-(float) gameWorldWidth
{
	// NSLog([NSString stringWithFormat:@"GameWorldWitdth: %.2f", gameWorld.mapSize.width * tileSize]);
	return gameWorld.mapSize.width * tileSize;
}

-(float) gameWorldHeight
{
	return gameWorld.mapSize.height * tileSize;
}

-(void) OnMapAction:(MapAction) kt
{
	
	switch (kt) {
		case kUp:
			mapY = mapY - 2;
			break;
		case kDown:
			mapY = mapY + 2;
			break;
		case kLeft:
			mapX = mapX + 2;
			break;
		case kRight:
			mapX = mapX - 2;
			break;
		default:
			break;
	}
	
	// Reset the map if the next position is past the edge
	if(mapX > 0) mapX = 0;
	if(mapY > 0) mapY = 0;
	
	if(mapX < -([self gameWorldWidth] - screenWidth)) mapX = -([self gameWorldWidth] - screenWidth);
	if(mapY < -([self gameWorldHeight] - screenHeight)) mapY = -([self gameWorldHeight] - screenHeight);
	
	gameWorld.position = ccp(mapX, mapY);
	
	// NSLog([NSString stringWithFormat:@"%.2f, %.2f %.2f, %.2f", tank.position.x, tank.position.y, gameWorld.position.x, gameWorld.position.y]);	
	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
