//
//  TankSprite.h
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BulletSprite.h"

typedef enum {
	kUp =  1,
	kLeft = 2,
	kRight = 3,
	kDown = 4,
	kFire = 5,
	kStay = 6,
} TankAction;

@interface TankSprite : CCSprite {

	TankAction kAct;
	CCLayer *gLayer;
	BulletSprite *bullet;
	
	bool bIsEnemy;
	
	float runSpeed, turnSpeed, moveStep; 
	
	int nRandomActionCount;
	
}

@property (nonatomic,readwrite,assign) TankAction kAct;
@property (nonatomic,readwrite,assign) bool bIsEnemy;

+ (id) TankWithinLayer:(CCLayer *)layer imageFile:(NSString*)imgFile;

- (void) SetLayer:(CCLayer *)layer; 
- (void) TankInit;
- (void) MoveLeft:(CCLayer *)layer;
- (void) MoveRight:(CCLayer *)layer;
- (void) MoveUp:(CCLayer *)layer;
- (void) MoveDown:(CCLayer *)layer;
- (void) OnFire:(CCLayer *)layer;
- (void) OnStay:(CCLayer *)layer;

- (void) Activate;
- (void) DoRandomAction;
- (void) KeepPlay;
- (void) Kill;


- (void) CheckExplosion;

@end

