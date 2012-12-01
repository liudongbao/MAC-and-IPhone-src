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
@synthesize enemyList;
@synthesize tank;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		// Load level map
		gameWorld = [CCTMXTiledMap tiledMapWithTMXFile:@"Level1.tmx"];
		[self addChild:gameWorld z:0 tag:9];
		
		// indecator
		CCSprite *spriteInd = [CCSprite spriteWithFile:@"enemy.png" rect:CGRectMake(0,0,40,40)];
		[self addChild:spriteInd z:1 tag:5];
		
		spriteInd.scale = 0.8;
		spriteInd.position = ccp(20, 300);
		
		lbEnemy = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"00" fntFile:@"font09.fnt"];
		lbEnemy.anchorPoint = ccp(0.0, 1.0);
		lbEnemy.scale = 0.8;
		[self addChild:lbEnemy z:1 tag:6];
		lbEnemy.position = ccp(40, 305);
		
		// Check Game Stae
		[self schedule:@selector(ShowState) interval: 0.5];
		
		// tank
		tank = [TankSprite TankWithinLayer:self imageFile:@"Tank.PNG"];
		[tank setPosition:ccp(20, 20)];
		tank.bIsEnemy = NO;
		
		// enemy
		enemyList = [[NSMutableArray alloc] initWithCapacity:8];
		
		int i;
		TankSprite * enemyOne;
		
		for (i = 0; i < 10; i++) {
			enemyOne = [TankSprite TankWithinLayer:self imageFile:@"enemy.png"];
			[enemyOne setPosition:ccp(i * 80 - 20, 560)];
			enemyOne.bIsEnemy = YES;
			[enemyOne Activate];			

			[enemyList addObject:enemyOne];
		}
		
		// explode1
		SheetExplode = [CCSpriteSheet spriteSheetWithFile:@"Explode1.png" capacity:10];
		[gameWorld addChild:SheetExplode z:0];
		
		spriteExplode = [CCSprite spriteWithTexture:SheetExplode.texture rect:CGRectMake(0,0,23,23)];
		[SheetExplode addChild:spriteExplode z:1 tag:5];
		spriteExplode.position = ccp(240, 160);
		[spriteExplode setVisible:NO];

		// explode2
		SheetExplodeBig = [CCSpriteSheet spriteSheetWithFile:@"exploBig.png" capacity:15];
		[gameWorld addChild:SheetExplodeBig z:0];
		
		spriteExplodeBig = [CCSprite spriteWithTexture:SheetExplodeBig.texture rect:CGRectMake(0,0,40,40)];
		[SheetExplodeBig addChild:spriteExplodeBig z:1 tag:5];
		spriteExplodeBig.position = ccp(240, 160);
		[spriteExplodeBig setVisible:NO];
		
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


-(void) ShowState
{
	int ne;
	
	ne = 0;
	
	for( TankSprite *pts in enemyList ) 
	{
		if (pts.visible)
			ne++;
	}
	
	[lbEnemy setString:[NSString stringWithFormat:@"%2d", ne]];
}

-(unsigned int)TiltIDFromPosition:(CGPoint)pos
{
	CGPoint cpt = [self tileCoordinateFromPos:pos];
	CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
	
	if (cpt.x < 0)
		return -1;
	
	if (cpt.y < 0)
		return -1;
	
	if (cpt.x >= ly.layerSize.width)
		return -1;
	
	if (cpt.y >= ly.layerSize.height)
		return -1;
	
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

-(void) ShowBigExplodeAt:(CGPoint) posAt
{
	int nSize;
	
	nSize = 40;
	
	[spriteExplodeBig setPosition:posAt];
	[spriteExplodeBig setVisible:YES];
	
	CCAnimation *animation = [CCAnimation animationWithName:@"expBig" delay:0.1f];
	for(int i=0;i<14;i++) {
		[animation addFrameWithTexture:SheetExplodeBig.texture rect:CGRectMake(i*nSize, 0, nSize, nSize) ];
	}				
	
	id action = [CCAnimate actionWithAnimation: animation];
	id ac = [CCSequence actions: action, [CCHide action], nil];
	
	[spriteExplodeBig runAction:ac];	
	
}

-(CGPoint)tileCoordinateFromPos:(CGPoint)pos
{
	int cox, coy;

	CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
	
	if (ly == nil)
	{
		NSLog(@"ERROR: Layer not found!");
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
	return;
	
	UITouch *touch = [touches anyObject];	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	CGPoint cpt = [self tileCoordinateFromPos:touchPoint];
	if (cpt.x != -1)
	{
		CCTMXLayer *ly = [gameWorld layerNamed:@"tile"];
		CCSprite *pTile = [ly tileAt:cpt];
	
		[pTile runAction:[CCBlink actionWithDuration:2 blinks:3]];
	}
	else {
		NSLog(@"No tile there!");
	}
	
//	[self ShowExplodeAt:CGPointMake(touchPoint.x, touchPoint.y)];
	
	return;
	
}

-(void) SetCameraPosition
{

	float x, y;
	
	x = tank.position.x;
	y = tank.position.y;
	
	[[self camera] setEyeX:x eyeY:y eyeZ:viewOrgZ];
	[[self camera] setCenterX:x centerY:y centerZ:0];	
	
	
/*	
	float x, y, z;
	[[self camera] eyeX:&x eyeY:&y eyeZ:&z];
	[[self camera] setEyeX:x - 20 eyeY:y - 20 eyeZ:z];
	
	[[self camera] centerX:&x centerY:&y centerZ:&z];
	[[self camera] setCenterX:x - 20 centerY:y - 20 centerZ:z];	
*/	
	
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

- (void) setWorldPosition
{	
	
	CGRect rc;
	
	rc = [tank textureRect];
	
	// NSLog([NSString stringWithFormat:@"Map Pos - tank.x =  %.2f, tank width = %.2f ", tank.position.x, rc.size.width]);
	
	// Check if the dozer is near the edge of the map
	if(tank.position.x < screenWidth/2 - rc.size.width / 2)
		mapX = 0;
	else if(tank.position.x > [self gameWorldWidth] - (screenWidth / 2))
		mapX = -[self gameWorldWidth];
	else
		mapX = -(tank.position.x - (screenWidth/2) + rc.size.width / 2);
	
	if(tank.position.y < screenHeight/2 - rc.size.height / 2)
		mapY = 0;
	else if(tank.position.y > [self gameWorldHeight] - (screenHeight/2))
		mapY = -[self gameWorldHeight];
	else
		mapY = -(tank.position.y - (screenHeight/2) + rc.size.height / 2);
	
	// Reset the map if the next position is past the edge
	if(mapX > 0) mapX = 0;
	if(mapY > 0) mapY = 0;
	
	if(mapX < -([self gameWorldWidth] - screenWidth)) mapX = -([self gameWorldWidth] - screenWidth);
	if(mapY < -([self gameWorldHeight] - screenHeight)) mapY = -([self gameWorldHeight] - screenHeight);
	
	// [gameWorld setPosition:ccp(mapX, mapY)];
	gameWorld.position = ccp(mapX, mapY);
	
}


-(void) OnTankAction:(TankAction) kt
{
	
	switch (kt) {
		case kUp:
			[tank MoveUp:self];
			break;
		case kDown:
			[tank MoveDown:self];
			break;
		case kLeft:
			[tank MoveLeft:self];
			break;
		case kRight:
			[tank MoveRight:self];
			break;
		case kFire:
			[tank OnFire:self];
			break;
		case kStay:
			[tank OnStay:self];
		default:
			break;
	}
	
	[self setWorldPosition];

	// NSLog([NSString stringWithFormat:@"%.2f, %.2f %.2f, %.2f", tank.position.x, tank.position.y, gameWorld.position.x, gameWorld.position.y]);	
	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[enemyList removeAllObjects];
	[enemyList release];
	[super dealloc];
}
@end
