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
	// This requires a temporary variable because you can't modify player.position.x directly. Objective-C properties
	// work a little different than what you may be used to from other languages. The problem is that player.position
	// actually is a method call [player position] and you simply can't change a member ".x" of that method. In other words,
	// you can't change members of struct properties like CGPoint, CGRect, CGSize directly through a property getter method.
	CGPoint pos = player.position;
	pos.x += acceleration.x * 10;
	player.position = pos;
	
	// Alternatively you could re-write the above 3 lines as follows. I find the above more readable however.
	// player.position = CGPointMake(player.position.x + acceleration.x, player.position.y);

	// The seemingly obvious alternative won't work in Objective-C! It'll give you the following error.
	// ERROR: lvalue required as left operand of assignment
	// player.position.x += acceleration.x * 10;
}


@end
