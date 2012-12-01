//
//  BulletSprite.m
//  T06
//
//  Created by ZhuYi on 10/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BulletSprite.h"
#import "GameLayer.h"

@implementation BulletSprite

+ (id) BulletWithinLayer:(CCLayer *)layer
{
	GameLayer *ly = (GameLayer *)layer;

	BulletSprite *sprite = [BulletSprite spriteWithFile:@"bullet.PNG" rect:CGRectMake(0, 0, 16, 16)];
	[ly.gameWorld addChild:sprite z:100];

	[sprite BulletInit];
	[sprite setVisible:NO];
	[sprite SetGamelayer:layer];
	
	return sprite;
}

- (void)SetGamelayer:(CCLayer *)layer
{
	gLayer = layer;
}

- (void) BulletInit
{

	emitter = [[CCParticleSmoke alloc] initWithTotalParticles:300];
	emitter.posVar = ccp(2, 2);
	emitter.startSize = 2;
	emitter.startSizeVar = 2;
	emitter.endSize = 5;
	emitter.endSizeVar = 3;
	
	emitter.angle = 0;
	emitter.angleVar = 360;
	
	emitter.speed = 20;
	emitter.speedVar = 10;
	
	emitter.life = 0.2;
	emitter.lifeVar = 0.0;
	emitter.gravity = ccp(0, 0);

//	ccColor4F startColor = {0.8f, 0.8f, 0.0f, 0.1f};
//	emitter.startColor = startColor;	
	
//	ccColor4F endColor = {0.8f, 0.8f, 0.0f, 0.1f};
	ccColor4F endColor = {0.0f, 0.0f, 0.0f, 0.3f};
	emitter.endColor = endColor;	


	emitter2 = [[CCParticleSun alloc] initWithTotalParticles:250];

	emitter2.posVar = ccp(3, 3);
	emitter2.startSize = 20;
	emitter2.startSizeVar = 2;
	emitter2.endSize = 0;
	emitter2.endSizeVar = 0;
	ccColor4F endColor2 = {0.0f, 0.0f, 0.0f, 0.1f};
	emitter2.endColor = endColor2;	
	
	// radial
//	emitter2.radialAccel = -120;
//	emitter2.radialAccelVar = 0;	
	
	[emitter stopSystem];
	[emitter2 stopSystem];
	
	[self addChild: emitter];
	[emitter release];
	
	[self addChild: emitter2];
	[emitter2 release];
	

}

- (void)FireFrom:(CGPoint)ptFrom To:(CGPoint)ptTo bulletType:(int)bType
{
	[self setPosition:ptFrom];
	
	id ac1 = [CCShow action];
	id ac2 = [CCMoveTo actionWithDuration:5 position:ptTo];
	id seq = [CCSequence actions:ac1, ac2, nil];
	
	
	if (bType == 1)
	{
		emitter.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
		[emitter resetSystem];
	}
	else
	{
		emitter2.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
		[emitter2 resetSystem];
	}
	
	[self runAction:seq];	
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
