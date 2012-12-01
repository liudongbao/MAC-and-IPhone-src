
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCSprite *_player;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCSprite *player;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
