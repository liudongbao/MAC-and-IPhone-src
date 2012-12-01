//
//  GameLayer.h
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	kUp =  1,
	kLeft = 2,
	kRight = 3,
	kDown = 4,
	kFire = 5,
	kStay = 6,
} MapAction;


@interface GameLayer : CCLayer {
	
	CCSprite *spriteExplode;
	CCSpriteSheet *SheetExplode;
	
	CCTMXTiledMap *gameWorld;
	
	float viewOrgX, viewOrgY, viewOrgZ;	
	
	float screenWidth, screenHeight, tileSize;
	
	float mapX, mapY;
	
	// user avatar action state, only one action allow.

}

@property (nonatomic,readwrite,assign) float mapX;
@property (nonatomic,readwrite,assign) float mapY;
@property (nonatomic,readwrite,assign) float screenWidth;
@property (nonatomic,readwrite,assign) float screenHeight;
@property (nonatomic,readwrite,assign) float tileSize;
@property (nonatomic,readwrite,assign) CCTMXTiledMap * gameWorld;

-(void) ShowExplodeAt:(CGPoint) posAt;

-(unsigned int) TiltIDFromPosition:(CGPoint)pos;
-(CGPoint) tileCoordinateFromPos:(CGPoint)pos;
-(void) DestpryTile:(CGPoint)pos;
-(void) OnMapAction:(MapAction)kt;

-(float) gameWorldWidth;
-(float) gameWorldHeight;

@end
