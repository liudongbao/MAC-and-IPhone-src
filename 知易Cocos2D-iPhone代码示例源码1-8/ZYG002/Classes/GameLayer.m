//
//  GameLayer.m
//  G03
//
//  Created by Mac Admin on 15/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SysMenu.h"


@implementation GameLayer

- (id) init
{
	self = [super init];
	if (self)
	{
		CCSprite *sp = [CCSprite spriteWithFile:@"Space.png"];
		sp.anchorPoint = CGPointZero;
		sp.opacity = 100;
		[self addChild:sp z:0 tag:1];
		
		// Add Status Items
		
		CCBitmapFontAtlas *lbScore = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Time: 0" fntFile:@"font09.fnt"];
		lbScore.anchorPoint = ccp(1.0, 1.0);
		lbScore.scale = 0.6;
		[self addChild:lbScore z:1 tag:3];
		lbScore.position = ccp(310, 450);
		

		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"flight.png" capacity:5];
		[self addChild:mgr z:0 tag:4];
		
		CCSprite *sprite = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake(0,0,31,30) ];
		[mgr addChild:sprite z:1 tag:5];
		
		sprite.scale = 1.1;
		sprite.anchorPoint = ccp(0, 1);
		sprite.position = ccp(10, 460);
		
		CCBitmapFontAtlas *lbLife = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"3" fntFile:@"font09.fnt"];
		lbLife.anchorPoint = ccp(0.0, 1.0);
		lbLife.scale = 0.6;
		[self addChild:lbLife z:1 tag:6];
		lbLife.position = ccp(50, 450);
		
		
		// change score
		[self schedule:@selector(step:) interval:1];
		
		
		// Add flight

		flight = [CCSprite spriteWithTexture:mgr.texture rect:CGRectMake(0,0,31,30)];
		flight.position = ccp(160, 30);
		flight.scale = 1.6;
		[mgr addChild:flight z:1 tag:99];
		
		CCAnimation *animation = [CCAnimation animationWithName:@"flight" delay:0.2f];
		for(int i=0;i<3;i++) {
			int x= i % 3;
			[animation addFrameWithTexture:mgr.texture rect:CGRectMake(x*32, 0, 31, 30) ];
		}		

		id action = [CCAnimate actionWithAnimation: animation];
		[flight runAction:[CCRepeatForever actionWithAction:action]];		
		
		// accept touch now!
		self.isTouchEnabled = YES;		
		
	}
	
	return self;
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	
	[flight runAction: [CCMoveTo actionWithDuration:1 position:ccp(convertedLocation.x, convertedLocation.y)]];

	
	return;
}

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"Time: %d", (int)time];
	
	CCBitmapFontAtlas *label1 = (CCBitmapFontAtlas*) [self getChildByTag:3];
	[label1 setString:string];
}

- (void) dealloc
{
	[super dealloc];
}

@end
