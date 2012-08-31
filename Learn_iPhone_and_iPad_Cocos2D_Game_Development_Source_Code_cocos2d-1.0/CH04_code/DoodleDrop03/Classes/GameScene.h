//
//  GameScene.h
//  DoodleDrop
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer 
{
	CCSprite* player;
	CGPoint playerVelocity;
}

+(id) scene;

@end
