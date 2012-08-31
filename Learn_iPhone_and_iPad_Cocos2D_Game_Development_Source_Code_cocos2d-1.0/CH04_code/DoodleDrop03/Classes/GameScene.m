//
//  GameScene.m
//  DoodleDrop
//

#import "GameScene.h"

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
	}

	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	// No need to release the player variable here, we did not retain it and cocos2d will automatically release it for us.

	// Never forget to call [super dealloc]!
	[super dealloc];
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
