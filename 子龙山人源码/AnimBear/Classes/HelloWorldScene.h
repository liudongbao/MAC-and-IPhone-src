
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
    CCSprite *_bear;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@property (nonatomic, retain) CCSprite *bear;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;

@end
