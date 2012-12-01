
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
    CCSprite *_player;
    CCSprite *_curBg;
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	int _projectilesDestroyed;
    CCSprite *_nextProjectile;
    int _score;
    int _oldScore;
    CCLabelTTF *_scoreLabel;
}

-(void)reset;
@property (nonatomic, retain) CCSprite *curBg;
@property (nonatomic, assign) CCLabelTTF *scoreLabel;
@property (nonatomic, retain) CCSprite *nextProjectile;

@end

@interface HelloWorldScene : CCScene {
	HelloWorld *_layer;
}

@property (nonatomic, retain) HelloWorld *layer;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
