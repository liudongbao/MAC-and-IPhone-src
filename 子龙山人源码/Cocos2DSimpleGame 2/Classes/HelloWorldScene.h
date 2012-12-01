
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
    CCSprite *_player;
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	int _projectilesDestroyed;
    CCSprite *_nextProjectile;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
