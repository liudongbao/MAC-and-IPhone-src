//
//  HelloWorldLayer.m
//  CCLabel-FastAndSlow
//
//  Created by Steffen Itterheim on 22.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"

@interface HelloWorld (Private)
-(void) createMovingSpriteAtHeight:(float)height;
-(void) updateInfoString;

@end

// ===============================================================

// Visit http://www.learn-cocos2d.com for the Bitmap Font Tutorial

// ===============================================================


@implementation HelloWorld

+(id) scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		self.isTouchEnabled = YES;
		
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCLabelTTF* label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
		label.position = CGPointMake(size.width / 2, size.height);
		label.anchorPoint = CGPointMake(0.5f, 1);
		[self addChild:label z:0 tag:1];
		
		mode = 3;
		[self updateInfoString];

		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"tap screen to cycle modes" fontName:@"Marker Felt" fontSize:20];
		label2.position = CGPointMake(size.width / 2, 0);
		label2.anchorPoint = CGPointMake(0.5f, 0);
		[self addChild:label2 z:0 tag:2];

		CCLabelTTF* label3 = [CCLabelTTF labelWithString:@"Note: run this on the device! Simulator performance is irrelevant!" fontName:@"Arial" fontSize:14];
		label3.position = CGPointMake(size.width / 2, [label2 texture].contentSize.height + 10);
		label3.anchorPoint = CGPointMake(0.5f, 0);
		[self addChild:label3 z:0 tag:3];
		
		score = 10;
		scoreLabel = [CCLabelTTF labelWithString:@"10" fontName:@"Arial" fontSize:40];
		scoreLabel.position = CGPointMake(size.width / 2, size.height / 2);
		scoreLabel.color = ccGREEN;
		[self addChild:scoreLabel];

		[self createMovingSpriteAtHeight:size.height / 1.5f];
		[self createMovingSpriteAtHeight:size.height / 3];
		
		[self schedule:@selector(updateOncePerSecond:) interval:1];
		[self scheduleUpdate];
	}
	return self;
}

-(void) createMovingSpriteAtHeight:(float)height
{
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite* sprite = [CCSprite spriteWithFile:@"Icon.png"];
	sprite.position = CGPointMake(0, height);
	[self addChild:sprite];
	
	float duration = height / 100;
	CCMoveTo* move1 = [CCMoveTo actionWithDuration:duration position:CGPointMake(size.width, sprite.position.y)];
	CCMoveTo* move2 = [CCMoveTo actionWithDuration:duration position:CGPointMake(0, sprite.position.y)];
	CCSequence* seq = [CCSequence actions:move1, move2, nil];
	CCRepeatForever* repeat = [CCRepeatForever actionWithAction:seq];
	[sprite runAction:repeat];
}

-(void) updateInfoString
{
	CCLabelTTF* info = (CCLabelTTF*)[self getChildByTag:1];

	mode++;
	if (mode > 3)
	{
		mode = 0;
	}
	
	switch (mode)
	{
		case 0:
			[info setString:@"LabelTTF, not updating"];
			scoreLabel.color = ccGREEN;
			break;
		case 1:
			[info setString:@"LabelTTF, updating once per second"];
			scoreLabel.color = ccYELLOW;
			break;
		case 2:
			[info setString:@"LabelTTF, updating every frame"];
			scoreLabel.color = ccORANGE;
			break;
		case 3:
			[info setString:@"LabelTTF, updating 50 times per frame"];
			scoreLabel.color = ccRED;
			break;
	}
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateInfoString];
}

-(void) updateScoreString
{
	score++;
	NSString* scoreString = [NSString stringWithFormat:@"%i", score];
	[scoreLabel setString:scoreString];

	if (mode == 3)
	{
		// update label several times to simulate multiple label updates per frame
		for (int i = 0; i < 50; i++)
		{
			[scoreLabel setString:scoreString];
		}
	}
}

-(void) updateOncePerSecond:(ccTime)delta
{
	if (mode == 1)
	{
		[self updateScoreString];
	}
}

-(void) update:(ccTime)delta
{
	if (mode >= 2)
	{
		[self updateScoreString];
	}
}

-(void) dealloc
{
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
