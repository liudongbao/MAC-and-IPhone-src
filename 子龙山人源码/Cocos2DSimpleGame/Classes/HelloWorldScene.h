
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	int _projectilesDestroyed;
}

- (void)pauseGame;
    
@end

@interface HelloWorldScene : CCScene
{
    HelloWorld *_layer;
}
@property (nonatomic, retain) HelloWorld *layer;
@end

