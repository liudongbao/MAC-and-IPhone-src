//
//  TankSprite.m
//  T06
//
//  Created by ZhuYi on 10/5/09.
//  Copyright moveStep09 __MyCompanyName__. All rights reserved.
//

#import "TankSprite.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@implementation TankSprite

@synthesize kAct;
@synthesize bIsEnemy;


+ (id) TankWithinLayer:(CCLayer *) layer imageFile:(NSString*) imgFile
{
	
	GameLayer *ly = (GameLayer *)layer;
	
	CCSpriteSheet *animationsSheet = [CCSpriteSheet spriteSheetWithFile:imgFile capacity:3];
	[ly.gameWorld addChild:animationsSheet z:99 tag:1];		
	
	TankSprite *sprite = [TankSprite spriteWithTexture:animationsSheet.texture rect:CGRectMake(0, 0, 40, 40)];
	[animationsSheet addChild:sprite z:0 tag:1];

	[sprite SetLayer:layer];
	[sprite TankInit];

	return sprite;
}

- (void) Activate
{
	CCAnimation *animation = [CCAnimation animationWithName:@"ac01" delay:0.2f];
	
	[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"e01"]];
	[animation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"e02"]];
	
	id action = [CCAnimate actionWithAnimation: animation];
	[self runAction:[CCRepeatForever actionWithAction:action]];		

	[self schedule:@selector(DoRandomAction) interval: 3];
}

- (void) Kill
{
	[self unschedule:@selector(KeepPlay)];
	[self unschedule:@selector(DoRandomAction)];
}

- (void) DoRandomAction
{
	float rand = CCRANDOM_0_1();
	
	if( rand < 0.20 )
		kAct = kUp;
	else if(rand < 0.50)
		kAct = kLeft;
	else if( rand < 0.80)
		kAct = kRight;
	else 
		kAct = kDown;

	nRandomActionCount = 0;
	[self schedule:@selector(KeepPlay) interval: 1/30];
}

- (void) KeepPlay
{
	switch (kAct) {
		case kUp:
			[self MoveUp:gLayer];
			break;
		case kDown:
			[self MoveDown:gLayer];
			break;
		case kLeft:
			[self MoveLeft:gLayer];
			break;
		case kRight:
			[self MoveRight:gLayer];
			break;
		default:
			break;
	}	
	nRandomActionCount = nRandomActionCount + 1;
	if (nRandomActionCount >= 75)
	{
		[self unschedule:@selector(KeepPlay)];
		[self OnFire:gLayer];
	}
}

- (void) SetLayer: (CCLayer *)layer
{
	gLayer = layer;
}

- (void) TankInit
{
	turnSpeed = 10;
	moveStep = 2;
	
	kAct = kStay;
	bullet = [BulletSprite BulletWithinLayer:gLayer];
}

- (void) OnFire:(CCLayer *)layer
{
	CGPoint ptTgt;
	
	switch (kAct) {
		case kUp:
			[bullet setPosition:ccp(self.position.x, self.position.y  + self.textureRect.size.height / 2)];
			ptTgt = ccp(self.position.x, self.position.y + 1024);
			break;
		case kDown:
			[bullet setPosition:ccp(self.position.x, self.position.y - self.textureRect.size.height / 2)];
			ptTgt = ccp(self.position.x, self.position.y - 1024);
			break;
		case kRight:
			[bullet setPosition:ccp(self.position.x  + self.textureRect.size.width / 2, self.position.y)];
			ptTgt = ccp(self.position.x + 1024, self.position.y);
			break;
		case kLeft:
			[bullet setPosition:ccp(self.position.x - self.textureRect.size.width / 2, self.position.y)];
			ptTgt = ccp(self.position.x - 1024, self.position.y);
			break;
		default:
			break;
	}
	
	id ac1 = [CCShow action];
	id ac2 = [CCMoveTo actionWithDuration: 5 position:ptTgt];
	id seq = [CCSequence actions:ac1, ac2, nil];
	[bullet runAction:seq];
	
	[self schedule:@selector(CheckExplosion) interval: 1/30];
	
}


- (void)CheckExplosion
{
	GameLayer *ly = (GameLayer *)gLayer;
	
	unsigned int tid;

	tid = [ly TiltIDFromPosition:bullet.position];

	// CCLOG([NSString stringWithFormat:@"x=%.2f, y=%.2f, id = %x", bullet.position.x, bullet.position.y, tid]);
	
	// Check hit compeletor:
	CGRect rc;
	
	if (bIsEnemy)
	{
		rc = CGRectMake(ly.tank.position.x - ly.tank.textureRect.size.width / 2, ly.tank.position.y - ly.tank.textureRect.size.height /2, ly.tank.textureRect.size.width, ly.tank.textureRect.size.height);

		if( CGRectContainsPoint( rc, bullet.position))
		{
			[self unschedule:@selector(CheckExplosion)];
			
			[bullet stopAllActions];
			[bullet setVisible:NO];
			
			[ly.tank stopAllActions];
			[ly.tank Kill];
			
			[ly ShowBigExplodeAt:ly.tank.position];
			
			id ac = [CCTintBy actionWithDuration:0.2 red:0 green:255 blue:255];
			id seq = [CCSequence actions: ac, [CCHide action], nil];
			
			[ly.tank runAction:seq];
			
		}
		
	}
	else
	{
		for( TankSprite *pts in ly.enemyList ) 
		{
			if (pts.visible)
			{
				rc = CGRectMake(pts.position.x - pts.textureRect.size.width / 2, pts.position.y - pts.textureRect.size.height /2, pts.textureRect.size.width, pts.textureRect.size.height);
				
//				NSLog([NSString stringWithFormat:@" --- Bullet :%.2f, %.2f, Rect: %.2f, %.2f", bullet.position.x, bullet.position.y, rc.origin.x, rc.origin.y]);
				
				if( CGRectContainsPoint( rc, bullet.position))
				{
					[self unschedule:@selector(CheckExplosion)];
				
					[bullet stopAllActions];
					[bullet setVisible:NO];
				
					[pts stopAllActions];
					[pts Kill];
					
					[ly ShowBigExplodeAt:pts.position];

					id ac = [CCTintBy actionWithDuration:0.2 red:0 green:255 blue:255];
					id seq = [CCSequence actions: ac, [CCHide action], nil];
				
					[pts runAction:seq];
				
					break;
				}
			}
		}
		
	}
	
	// Check hit wall.
	if (tid != 4)
	{
		if (tid != 0)
		{
			CGPoint ptd;
			
			[self unschedule:@selector(CheckExplosion)];
		
			[bullet stopAllActions];
			[bullet setVisible:NO];
			[ly ShowExplodeAt:bullet.position];
			
			if (tid == 2)
			{
				[ly DestpryTile:bullet.position];

				// Detroy adjecent tile
				
				ptd = ccp(bullet.position.x - ly.tileSize / 2, bullet.position.y);
				tid = [ly TiltIDFromPosition:ptd];
				if (tid == 2)
					[ly DestpryTile:ptd];

				ptd = ccp(bullet.position.x + ly.tileSize / 2, bullet.position.y);
				tid = [ly TiltIDFromPosition:ptd];
				if (tid == 2)
					[ly DestpryTile:ptd];
				
				ptd = ccp(bullet.position.x, bullet.position.y + ly.tileSize / 2);
				tid = [ly TiltIDFromPosition:ptd];
				if (tid == 2)
					[ly DestpryTile:ptd];
				
				ptd = ccp(bullet.position.x, bullet.position.y - ly.tileSize / 2);
				tid = [ly TiltIDFromPosition:ptd];
				if (tid == 2)
					[ly DestpryTile:ptd];
				
			}
		}
		else
		{
			[self unschedule:@selector(CheckExplosion)];
			[bullet stopAllActions];
			[bullet setVisible:NO];
		}
	}
	
}

- (void) MoveLeft:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;
	unsigned int tid;
	CGPoint npt;
	
	[self setRotation:-90];
	kAct = kLeft;
	
	npt = ccp(self.position.x - self.textureRect.size.width / 2 - moveStep, self.position.y);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;

	npt = ccp(self.position.x - self.textureRect.size.width / 2 - moveStep, self.position.y + self.textureRect.size.height / 4);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	npt = ccp(self.position.x - self.textureRect.size.width / 2 - moveStep, self.position.y - self.textureRect.size.height / 4);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	self.position = ccp(self.position.x - moveStep, self.position.y);
	
	// bound check
	if (self.position.x - ly.mapX < self.textureRect.size.width / 2)
		[self setPosition:ccp(self.textureRect.size.width / 2, self.position.y)];
	
}

- (void) MoveRight:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;
	unsigned int tid;
	CGPoint npt;
	
	[self setRotation:90];
	kAct = kRight;
	
	npt = ccp(self.position.x + self.textureRect.size.width / 2 + moveStep, self.position.y);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;

	npt = ccp(self.position.x + self.textureRect.size.width / 2 + moveStep, self.position.y + self.textureRect.size.height / 4);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	npt = ccp(self.position.x + self.textureRect.size.width / 2 + moveStep, self.position.y - self.textureRect.size.height / 4);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	[self setPosition:ccp(self.position.x + moveStep, self.position.y)];

	// bound check
	if ([ly gameWorldWidth] - self.position.x < self.textureRect.size.width / 2)
		[self setPosition:ccp([ly gameWorldWidth] - self.textureRect.size.width / 2, self.position.y)];
	
}

- (void) MoveUp:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;
	unsigned int tid;
	CGPoint npt;

	[self setRotation:0];
	kAct = kUp;
	
	npt = ccp(self.position.x, self.position.y + self.textureRect.size.height / 2 + moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;

	npt = ccp(self.position.x + self.textureRect.size.width / 4, self.position.y + self.textureRect.size.height / 2 + moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	npt = ccp(self.position.x - self.textureRect.size.width / 4, self.position.y + self.textureRect.size.height / 2 + moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	
	[self setPosition:ccp(self.position.x, self.position.y + moveStep)];
	// bound check
	if ([ly gameWorldHeight] - self.position.y < self.textureRect.size.height / 2)
		[self setPosition:ccp(self.position.x, [ly gameWorldHeight] - self.textureRect.size.height / 2)];
	
}

- (void) MoveDown:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;
	unsigned int tid;
	CGPoint npt;
	
	[self setRotation:180];
	kAct = kDown;
	
	npt = ccp(self.position.x, self.position.y - self.textureRect.size.height / 2 - moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;

	npt = ccp(self.position.x + self.textureRect.size.width / 4, self.position.y - self.textureRect.size.height / 2 - moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	npt = ccp(self.position.x - self.textureRect.size.width / 4, self.position.y - self.textureRect.size.height / 2 - moveStep);
	tid = [ly TiltIDFromPosition:npt];
	
	if (tid != 4)
		return;
	
	
	[self setPosition:ccp(self.position.x, self.position.y - moveStep)];
	
	// bound check
	if (self.position.y - ly.mapY < self.textureRect.size.height / 2)
		[self setPosition:ccp(self.position.x, self.textureRect.size.height / 2)];
	
}

- (void) OnStay:(CCLayer *)layer
{
	kAct = kStay;
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
