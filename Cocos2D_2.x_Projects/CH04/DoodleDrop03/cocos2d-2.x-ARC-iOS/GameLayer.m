//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Steffen Itterheim on 11.04.12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

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
		
		self.isAccelerometerEnabled = YES;
		
        player = [CCSprite spriteWithFile:@"alien.png"];
        [self addChild:player z:0 tag:1];
		
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        float imageHeight = player.texture.contentSize.height;
        player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		
		// schedules the –(void) update:(ccTime)delta method to be called every frame
		[self scheduleUpdate];
		[self initSpiders];
		
		
		scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:48];
		scoreLabel.position = CGPointMake(screenSize.width / 2, screenSize.height);
		// Adjust the label's anchorPoint's y position to make it align with the top.
		scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
		// Add the score label with z value of -1 so it's drawn below everything else
		[self addChild:scoreLabel z:-1];
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
	spiderMoveDuration = 4.0f;
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
	CGPoint belowScreenPosition = CGPointMake(spider.position.x,
											  -spider.texture.contentSize.height);
	CCMoveTo* move = [CCMoveTo actionWithDuration:spiderMoveDuration
										 position:belowScreenPosition];
	
	CCCallBlock* callDidDrop = [CCCallBlock actionWithBlock:^void(){
		// move the droppedSpider back up outside the top of the screen
		CGPoint pos = spider.position;
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		pos.y = screenSize.height + spider.texture.contentSize.height;
		spider.position = pos;
	}];
	
	CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
	[spider runAction:sequence];
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
	
	// update label test
	score = [CCDirector sharedDirector].totalFrames;
	[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
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
            // Game Over (just restart the game for now)
            [self resetGame];
            break;
        }
    }
}

-(void) resetGame
{
	[self resetSpiders];
	
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

// Only draw this debugging information in, well, debug builds.
#if DEBUG
-(void) draw
{
	[super draw];
	
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
}
#endif

@end
