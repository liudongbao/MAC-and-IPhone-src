//
//  GameLayer.h
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TankSprite.h"

@interface GameLayer : CCLayer {
	
	CCSprite *spriteExplode;
	CCSprite *spriteExplodeBig;
	
	CCSpriteSheet *SheetExplode;
	CCSpriteSheet *SheetExplodeBig;
	
	TankSprite *tank;
	
	CCTMXTiledMap *gameWorld;
	
	float viewOrgX, viewOrgY, viewOrgZ;	
	
	float screenWidth, screenHeight, tileSize;
	
	float mapX, mapY;
	
	NSMutableArray *enemyList;
	
	CCBitmapFontAtlas *lbEnemy;
	
}

@property (nonatomic,readwrite,assign) float mapX;
@property (nonatomic,readwrite,assign) float mapY;
@property (nonatomic,readwrite,assign) float screenWidth;
@property (nonatomic,readwrite,assign) float screenHeight;
@property (nonatomic,readwrite,assign) float tileSize;
@property (nonatomic,readwrite,assign) CCTMXTiledMap * gameWorld;
@property (nonatomic,readonly) NSMutableArray * enemyList;
@property (nonatomic,readonly) TankSprite * tank;


-(void) ShowExplodeAt:(CGPoint) posAt;
-(void) ShowBigExplodeAt:(CGPoint) posAt;

-(void) OnTankAction:(TankAction) kt;

-(unsigned int) TiltIDFromPosition:(CGPoint)pos;
-(CGPoint) tileCoordinateFromPos:(CGPoint)pos;
-(void) DestpryTile:(CGPoint)pos;

-(float) gameWorldWidth;
-(float) gameWorldHeight;

@end
