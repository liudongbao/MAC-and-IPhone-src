//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Steffen Itterheim on 11.04.12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer* layer = [GameLayer node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if ((self = [super init]))
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
		
		// set iPad version to use standard resolution images for iPad 1 & 2 and Retina images for iPad 3
		[[CCFileUtils sharedFileUtils] setiPadSuffix:@""];					// Default on iPad is "" (empty string)
		[[CCFileUtils sharedFileUtils] setiPadRetinaDisplaySuffix:@"-hd"];	// Default on iPad RetinaDisplay is "-ipadhd"
		
		self.isAccelerometerEnabled = YES;
		
        player = [CCSprite spriteWithFile:@"alien.png"];
        [self addChild:player z:0 tag:1];
		
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        float imageHeight = player.texture.contentSize.height;
        player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		
		// schedules the –(void) update:(ccTime)delta method to be called every frame
		[self scheduleUpdate];
		[self initSpiders];
		
		
		scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
		scoreLabel.position = CGPointMake(screenSize.width / 2, screenSize.height);
		// Adjust the label's anchorPoint's y position to make it align with the top.
		scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
		// Add the score label with z value of -1 so it's drawn below everything else
		[self addChild:scoreLabel z:-1];
		
		// Play the background music in an endless loop.
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"blues.mp3" loop:YES];
		
		// Preload the sound effect into memory so there's no delay when playing it the first time.
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"alien-sfx.caf"];
		
		// Seed the randomizer once with the current time. This way the game doesn't start with the same sequence
		// of spiders dropping every time it is started.
		srandom(time(NULL));
		
		// start with game over first
		[self showGameOver];
    }
	
    return self;
}

-(void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

-(void) initSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// using a temporary spider sprite is the easiest way to get the image's size
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"spider.png"];
	
	float imageWidth = [tempSpider texture].contentSize.width;
	
	// Use as many spiders as can fit next to each other over the whole screen width.
	int numSpiders = screenSize.width / imageWidth;
	
	// Initialize the spiders array using alloc.
	spiders = [NSMutableArray arrayWithCapacity:numSpiders];
	
	for (int i = 0; i < numSpiders; i++)
	{
		CCSprite* spider = [CCSprite spriteWithFile:@"spider.png"];
		[self addChild:spider z:0 tag:2];
		
		// Also add the spider to the spiders array.
		[spiders addObject:spider];
	}
	
	// call the method to reposition all spiders
	[self resetSpiders];
}

-(void) resetSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// Get any spider to get its image width
	CCSprite* tempSpider = [spiders lastObject];
	CGSize size = tempSpider.texture.contentSize;
	
	int numSpiders = [spiders count];
	for (int i = 0; i < numSpiders; i++)
	{
		// Put each spider at its designated position outside the screen
		CCSprite* spider = [spiders objectAtIndex:(NSUInteger)i];
		spider.position = CGPointMake(size.width * i + size.width * 0.5f,
									  screenSize.height + size.height);
		
		[spider stopAllActions];
	}
	
	// Schedule the spider update logic to run at the given interval.
	[self schedule:@selector(spidersUpdate:) interval:0.7f];
	
	// reset the moved spiders counter and spider move duration (affects speed)
	numSpidersMoved = 0;
	spiderMoveDuration = 8.0f;
}

-(void) spidersUpdate:(ccTime)delta
{
	// Try to find a spider which isn't currently moving.
	for (int i = 0; i < 10; i++)
	{
		int randomSpiderIndex = CCRANDOM_0_1() * spiders.count;
		CCSprite* spider = [spiders objectAtIndex:randomSpiderIndex];
		
		// If the spider isn't moving it won’t have any running actions.
		if (spider.numberOfRunningActions == 0)
		{
			// If you're curious how often the for i < 10 loop is actually run ...
			if (i > 0)
			{
				CCLOG(@"Dropping a Spider after %i retries.", i);
			}

			// This is the sequence which controls the spiders' movement
			[self runSpiderMoveSequence:spider];
			
			// Only one spider should start moving at a time.
			break;
		}
	}
}

-(void) runSpiderMoveSequence:(CCSprite*)spider
{
	// Slowly increase the spider speed over time.
	numSpidersMoved++;
	if (numSpidersMoved % 8 == 0 && spiderMoveDuration > 2.0f)
	{
		spiderMoveDuration -= 0.1f;
	}
	
	// This is the sequence which controls the spiders' movement.
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	CGPoint hangInTherePosition = CGPointMake(spider.position.x, screenSize.height - 3 * spider.texture.contentSize.height);
	CGPoint belowScreenPosition = CGPointMake(spider.position.x, -(3 * spider.texture.contentSize.height));
	CCMoveTo* moveHang = [CCMoveTo actionWithDuration:4 position:hangInTherePosition];
	CCEaseElasticOut* easeHang = [CCEaseElasticOut actionWithAction:moveHang period:0.8f];
	CCMoveTo* moveEnd = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
	CCEaseBackInOut* easeEnd = [CCEaseBackInOut actionWithAction:moveEnd];
	
	CCCallBlock* callDidDrop = [CCCallBlock actionWithBlock:^void(){
		// move the droppedSpider back up outside the top of the screen
		CGPoint pos = spider.position;
		pos.y = screenSize.height + spider.texture.contentSize.height;
		spider.position = pos;
	}];
	
	CCSequence* sequence = [CCSequence actions:easeHang, easeEnd, callDidDrop, nil];
	[spider runAction:sequence];
}

-(void) runSpiderWiggleSequence:(CCSprite*)spider
{
	// Do something icky with the spiders ...
	CCScaleTo* scaleUp = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:1.05f];
	CCEaseBackInOut* easeUp = [CCEaseBackInOut actionWithAction:scaleUp];
	CCScaleTo* scaleDown = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:0.95f];
	CCEaseBackInOut* easeDown = [CCEaseBackInOut actionWithAction:scaleDown];
	CCSequence* scaleSequence = [CCSequence actions:easeUp, easeDown, nil];
	CCRepeatForever* repeatScale = [CCRepeatForever actionWithAction:scaleSequence];
	[spider runAction:repeatScale];
}

-(void) update:(ccTime)delta
{
	// Keep adding up the playerVelocity to the player's position
	CGPoint pos = player.position;
	pos.x += playerVelocity.x;
	
	// The Player should also be stopped from going outside the screen
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float imageWidthHalved = player.texture.contentSize.width * 0.5f;
	float leftBorderLimit = imageWidthHalved;
	float rightBorderLimit = screenSize.width - imageWidthHalved;
	
	// preventing the player sprite from moving outside the screen
	if (pos.x < leftBorderLimit)
	{
		pos.x = leftBorderLimit;
		playerVelocity = CGPointZero;
	}
	else if (pos.x > rightBorderLimit)
	{
		pos.x = rightBorderLimit;
		playerVelocity = CGPointZero;
	}
	
	// assigning the modified position back
	player.position = pos;
	
	[self checkForCollision];
	
	// update score label
	if ([CCDirector sharedDirector].totalFrames % 60 == 0)
	{
		score++;
		[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
	}
}

-(void) checkForCollision
{
    // Assumption: both player and spider images are squares.
    float playerImageSize = player.texture.contentSize.width;
	CCSprite* spider = [spiders lastObject];
    float spiderImageSize = spider.texture.contentSize.width;
    float playerCollisionRadius = playerImageSize * 0.4f;
    float spiderCollisionRadius = spiderImageSize * 0.4f;
	
    // This collision distance will roughly equal the image shapes.
    float maxCollisionDistance = playerCollisionRadius + spiderCollisionRadius;
	
	
    int numSpiders = spiders.count;
    for (int i = 0; i < numSpiders; i++)
    {
        spider = [spiders objectAtIndex:i];
		
        if (spider.numberOfRunningActions == 0)
        {
            // This spider isn't even moving so we can skip checking it.
			continue;
        }
		
        // Get the distance between player and spider.
        float actualDistance = ccpDistance(player.position, spider.position);
		
        // Are the two objects closer than allowed?
        if (actualDistance < maxCollisionDistance)
        {
			[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];

            // Game Over (just restart the game for now)
            [self showGameOver];
            break;
        }
    }
}

-(void) resetGame
{
	// prevent screensaver from darkening the screen while the game is played
	[self setScreenSaverEnabled:NO];
	
	// remove game over label & touch to continue label
	[self removeChildByTag:100 cleanup:YES];
	[self removeChildByTag:101 cleanup:YES];
	
	// re-enable accelerometer
	self.isAccelerometerEnabled = YES;
	self.isTouchEnabled = NO;
	
	// put all spiders back to top
	[self resetSpiders];
	
	// re-schedule update
	[self scheduleUpdate];
	
	// reset score
	score = 0;
	[scoreLabel setString:@"0"];
}

-(void) accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration
{
	// controls how quickly velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.4f;
	// determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 6.0f;
	// how fast the velocity can be at most
	float maxVelocity = 100;
	
	// adjust velocity based on current accelerometer acceleration
	playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
	
	// we must limit the maximum velocity of the player sprite, in both directions
	if (playerVelocity.x > maxVelocity)
	{
		playerVelocity.x = maxVelocity;
	}
	else if (playerVelocity.x < - maxVelocity)
	{
		playerVelocity.x = - maxVelocity;
	}
}

-(void) draw
{
	[super draw];
	
	// Only draw this debugging information in, well, debug builds.
#if DEBUG
	// Iterate through all nodes of the layer.
	for (CCNode* node in [self children])
	{
		// Make sure the node is a CCSprite and has the right tags.
		if ([node isKindOfClass:[CCSprite class]] && (node.tag == 1 || node.tag == 2))
		{
			// The sprite's collision radius is a percentage of its image width.
			// The same factor is used in the checkForCollision method above.
			CCSprite* sprite = (CCSprite*)node;
			float radius = sprite.texture.contentSize.width * 0.4f;
			float angle = 0;
			int numSegments = 10;
			bool drawLineToCenter = NO;
			ccDrawCircle(sprite.position, radius, angle, numSegments, drawLineToCenter);
		}
	}
#endif
	
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	// always keep variables you have to calculate only once outside the loop
	float threadCutPosition = screenSize.height * 0.75f;
	
	// Draw a spider thread using OpenGL
	for (CCSprite* spider in spiders)
	{
		// only draw thread up to a certain point
		if (spider.position.y > threadCutPosition)
		{
			// vary thread position a little so it looks a bit more dynamic
			float threadX = spider.position.x + (CCRANDOM_0_1() * 2.0f - 1.0f);
			
			ccDrawColor4F(0.5f, 0.5f, 0.5f, 1.0f);
			ccDrawLine(spider.position, CGPointMake(threadX, screenSize.height));
		}
	}
}

#pragma mark Reset Game
// The game is played only using the accelerometer. The screen may go dark while playing because the player
// won't touch the screen. This method allows the screensaver to be disabled during gameplay.
-(void) setScreenSaverEnabled:(bool)enabled
{
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
}

-(void) showGameOver
{
	// Re-enable screensaver, to prevent battery drain in case the user puts the device aside without turning it off.
	[self setScreenSaverEnabled:YES];
	
	// have everything stop
	for (CCNode* node in self.children)
	{
		[node stopAllActions];
	}
	
	// I do want the spiders to keep wiggling so I simply restart this here
	for (CCSprite* spider in spiders)
	{
		[self runSpiderWiggleSequence:spider];
	}
	
	// disable accelerometer input for the time being
	self.isAccelerometerEnabled = NO;
	// but allow touch input now
	self.isTouchEnabled = YES;
	
	// stop the scheduled selectors
	[self unscheduleAllSelectors];
	
	// add the labels shown during game over
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCLabelTTF* gameOver = [CCLabelTTF labelWithString:@"GAME OVER!" fontName:@"Marker Felt" fontSize:60];
	gameOver.position = CGPointMake(screenSize.width / 2, screenSize.height / 3);
	[self addChild:gameOver z:100 tag:100];
	
	// game over label runs 3 different actions at the same time to create the combined effect
	// 1) color tinting
	CCTintTo* tint1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:0];
	CCTintTo* tint2 = [CCTintTo actionWithDuration:2 red:255 green:255 blue:0];
	CCTintTo* tint3 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:0];
	CCTintTo* tint4 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:255];
	CCTintTo* tint5 = [CCTintTo actionWithDuration:2 red:0 green:0 blue:255];
	CCTintTo* tint6 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	CCSequence* tintSequence = [CCSequence actions:tint1, tint2, tint3, tint4, tint5, tint6, nil];
	CCRepeatForever* repeatTint = [CCRepeatForever actionWithAction:tintSequence];
	[gameOver runAction:repeatTint];
	
	// 2) rotation with ease
	CCRotateTo* rotate1 = [CCRotateTo actionWithDuration:2 angle:3];
	CCEaseBounceInOut* bounce1 = [CCEaseBounceInOut actionWithAction:rotate1];
	CCRotateTo* rotate2 = [CCRotateTo actionWithDuration:2 angle:-3];
	CCEaseBounceInOut* bounce2 = [CCEaseBounceInOut actionWithAction:rotate2];
	CCSequence* rotateSequence = [CCSequence actions:bounce1, bounce2, nil];
	CCRepeatForever* repeatBounce = [CCRepeatForever actionWithAction:rotateSequence];
	[gameOver runAction:repeatBounce];
	
	// 3) jumping
	CCJumpBy* jump = [CCJumpBy actionWithDuration:3 position:CGPointZero height:screenSize.height / 3 jumps:1];
	CCRepeatForever* repeatJump = [CCRepeatForever actionWithAction:jump];
	[gameOver runAction:repeatJump];
	
	// touch to continue label
	CCLabelTTF* touch = [CCLabelTTF labelWithString:@"tap screen to play again" fontName:@"Arial" fontSize:20];
	touch.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
	[self addChild:touch z:100 tag:101];
	
	// did you try turning it off and on again?
	CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
	CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
	[touch runAction:repeatBlink];
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetGame];
}


@end
