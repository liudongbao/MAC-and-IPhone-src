//
//  GameScene.m
//  DoodleDrop
//

#import "GameScene.h"

// By adding another @interface with the same name of the class but adding an identifier in brackets
// you can define private class methods. These are methods which are only used in this class and should
// not be used by other classes. Adding these method definitions gets rid of the "may not respond to selector"
// warning messages. The warning messages are not the problem, the problem is when the warning holds true
// and one of the selectors really can't respond. Typically due to a spelling mistake. In that case the App
// would simply crash. It's good practice to get rid of "may not respond to selector" warnings since they can
// be important indicators to potential crashes.
@interface GameScene (PrivateMethods)
-(void) initSpiders;
-(void) resetSpiders;
-(void) spidersUpdate:(ccTime)delta;
-(void) runSpiderMoveSequence:(CCSprite*)spider;
-(void) spiderDidDrop:(id)sender;
@end

@implementation GameScene

+(id) scene
{
	// the usual ... create the scene and add our layer straight to it
	CCScene *scene = [CCScene node];
	CCLayer* layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

		// Yes, we want to receive accelerometer input events.
		self.isAccelerometerEnabled = YES;
		
		// Create and add the player sprite.
		// The player variable does not need to be retained because cocos2d retains it as long as it is a child
		// of this layer. If you ever were to remove the player sprite from this layer you have to set the player
		// variable to nil because its memory will then be released.
		player = [CCSprite spriteWithFile:@"alien.png"];
		[self addChild:player z:0 tag:1];
		
		// Placing the sprite - it should start horizontally centered and with its feet on the ground (bottom of screen).
		// To place the player at the bottom of the screen we take the player's bounding box. Because the Player's
		// texture is centered on its position we need to lift it up by half the height.
		// This is preferable to modifying the anchorPoint because we use the player position for collision detection
		// so it should remain at the center of the texture.
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		
		// scheduling the update method in order to adjust the player's speed every frame
		[self scheduleUpdate];
		
		[self initSpiders];
	}

	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	// No need to release the player variable here, we did not retain it and cocos2d will automatically release it for us.

	// The spiders array must be released because it was created using [CCArray alloc]
	[spiders release];
	
	// Never forget to call [super dealloc]!
	[super dealloc];
}

#pragma mark Spiders

-(void) initSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	// Creating a temporary spider sprite because its the easiest way to get the image's size
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"spider.png"];
	float imageWidth = [tempSpider texture].contentSize.width;
	// Note: by not adding the tempSpider as child its memory will be freed automatically!
	
	// There should be as many spiders as can fit next to each other over the whole screen width.
	// The number of spiders will automatically scale depending on the device's screen size.
	int numSpiders = screenSize.width / imageWidth;

	// Initialize the spiders array. Make sure it hasn't been initialized before.
	NSAssert(spiders == nil, @"%@: spiders array is already initialized!", NSStringFromSelector(_cmd));
	spiders = [[CCArray alloc] initWithCapacity:numSpiders];
	
	for (int i = 0; i < numSpiders; i++)
	{
		// Creating a spider sprite, positioning will be done later
		CCSprite* spider = [CCSprite spriteWithFile:@"spider.png"];
		[self addChild:spider z:0 tag:2];
		
		// Also add the spider to the spiders array so it can be accessed more easily.
		[spiders addObject:spider];
	}
	
	[self resetSpiders];
}

// Positioning the Spiders is seperated into another method because Spiders will need to be re-positioned
// after game over. This is more effective than throwing away all spider CCSprites and re-creating them.
-(void) resetSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	int numSpiders = [spiders count];
	
	if (numSpiders > 0)
	{
		// Get any spider to get its image width
		CCSprite* tempSpider = [spiders lastObject];
		CGSize imageSize = [tempSpider texture].contentSize;
		
		for (int i = 0; i < numSpiders; i++)
		{
			// Adjust each spider's horizontal position to be spread across the screen width, one next to the other.
			// The vertical position will be just above the upper screen edge so that the spiders are all off-screen.
			CCSprite* spider = [spiders objectAtIndex:i];
			spider.position = CGPointMake(imageSize.width * i + imageSize.width * 0.5f, screenSize.height + imageSize.height);
		}
	}
	
	// Unschedule the selector just in case. If it isn't scheduled it won't do anything.
	[self unschedule:@selector(spidersUpdate:)];
	// Schedule the spider update logic to run at the given interval.
	[self schedule:@selector(spidersUpdate:) interval:0.7f];
	
	// reset the moved spiders counter and spider move duration (affects spider's speed)
	numSpidersMoved = 0;
	spiderMoveDuration = 4.0f;
}

-(void) spidersUpdate:(ccTime)delta
{
	// Try to find a spider which isn't currently moving for an arbitrary number of times.
	// If one isn't found within 10 tries we'll just try again next time spidersUpdate is called.
	for (int i = 0; i < 10; i++)
	{
		int randomSpiderIndex = CCRANDOM_0_1() * [spiders count];
		CCSprite* spider = [spiders objectAtIndex:randomSpiderIndex];
		
		// If the spider isn't moving it should have no running actions, in that case it's ready to go.
		if ([spider numberOfRunningActions] == 0)
		{
			// If you're curious how often the for i < 10 loop is actually run ...
			if (i > 0)
			{
				CCLOG(@"Dropping a Spider after %i retries.", i);
			}

			[self runSpiderMoveSequence:spider];
			
			// We only want one spider to start moving at a time, so we'll end the for loop by using the break statement.
			break;
		}
	}
}

-(void) runSpiderMoveSequence:(CCSprite*)spider
{
	// By keeping track of the spiders which started moving we can slowly increase their speed over time.
	// In this case after every 8th spider the move duration will be decreased down to a minimum of 1 second.
	numSpidersMoved++;
	if (numSpidersMoved % 8 == 0 && spiderMoveDuration > 2.0f)
	{
		spiderMoveDuration -= 0.1f;
	}

	// This is the sequence which controls the spiders' movement. A CCCallFuncN is used to reset the
	// spider once it has moved outside the lower border of the screen, which is when it can be re-used.
	CGPoint belowScreenPosition = CGPointMake(spider.position.x, -[spider texture].contentSize.height);
	CCMoveTo* move = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
	CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(spiderDidDrop:)];
	CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
	[spider runAction:sequence];
}

// Called by CCCallFuncN whenever a spider has ended its sequence of actions. It means at this time the spider will be
// outside the bottom of the screen and can be moved back to outside the top of the screen.
-(void) spiderDidDrop:(id)sender
{
	// Make sure sender is actually of the right class.
	NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not of class CCSprite!");
	CCSprite* spider = (CCSprite*)sender;
	
	// move the spider back up outside the top of the screen
	CGPoint pos = spider.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.y = screenSize.height + [spider texture].contentSize.height;
	spider.position = pos;
}

// #pragma mark statements are a nice way to categorize your code and to use them as "bookmarks"
#pragma mark Accelerometer Input

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// These three values control how the player is moved. I call such values "design parameters" as they 
	// need to be tweaked a lot and are critical for the game to "feel right".
	// Sometimes, like in the case with deceleration and sensitivity, such values can affect one another.
	// For example if you increase deceleration, the velocity will reach maxSpeed faster while the effect
	// of sensitivity is reduced.
	
	// this controls how quickly the velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.4f;
	// this determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 6.0f;
	// how fast the velocity can be at most
	float maxVelocity = 100;

	// adjust velocity based on current accelerometer acceleration
	playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
	
	// we must limit the maximum velocity of the player sprite, in both directions (positive & negative values)
	if (playerVelocity.x > maxVelocity)
	{
		playerVelocity.x = maxVelocity;
	}
	else if (playerVelocity.x < -maxVelocity)
	{
		playerVelocity.x = -maxVelocity;
	}

	// Alternatively, the above if/else if block can be rewritten using fminf and fmaxf more neatly like so:
	// playerVelocity.x = fmaxf(fminf(playerVelocity.x, maxVelocity), -maxVelocity);
}

#pragma mark update

-(void) update:(ccTime)delta
{
	// Keep adding up the playerVelocity to the player's position
	
	// This requires a temporary variable because you can't modify player.position.x directly. Objective-C properties
	// work a little different than what you may be used to from other languages. The problem is that player.position
	// actually is a method call [player position] and you simply can't change a member ".x" of that method. In other words,
	// you can't change members of struct properties like CGPoint, CGRect, CGSize directly through a property getter method.
	CGPoint pos = player.position;
	pos.x += playerVelocity.x;
	
	// Alternatively you could re-write the above 3 lines as follows. I find the above more readable however.
	// player.position = CGPointMake(player.position.x + playerVelocity.x, player.position.y);
	
	// The seemingly obvious alternative won't work in Objective-C! It'll give you the following error.
	// ERROR: lvalue required as left operand of assignment
	// player.position.x += playerVelocity.x;
	
	// The Player should also be stopped from going outside the screen
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float imageWidthHalved = [player texture].contentSize.width * 0.5f;
	float leftBorderLimit = imageWidthHalved;
	float rightBorderLimit = screenSize.width - imageWidthHalved;

	// the left/right border check is performed against half the player image's size so that the sides of the actual
	// sprite are blocked from going outside the screen because the player sprite's position is at the center of the image
	if (pos.x < leftBorderLimit)
	{
		pos.x = leftBorderLimit;

		// also set velocity to zero because the player is still accelerating towards the border
		playerVelocity = CGPointZero;
	}
	else if (pos.x > rightBorderLimit)
	{
		pos.x = rightBorderLimit;

		// also set velocity to zero because the player is still accelerating towards the border
		playerVelocity = CGPointZero;
	}

	// Alternatively, the above if/else if block can be rewritten using fminf and fmaxf more neatly like so:
	// pos.x = fmaxf(fminf(pos.x, rightBorderLimit), leftBorderLimit);
	
	player.position = pos;
}

@end
