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
	
	// CCArray is cocos2d's undocumented array class optimized to perform better than NSArray.
	// You can find the class' implementation in the cocos2d/support folder.
	CCArray* spiders;
	
	float spiderMoveDuration;
	int numSpidersMoved;
	
	// Used for Scores
	ccTime totalTime;
	int score;
	CCLabelBMFont* scoreLabel;
}

+(id) scene;

@end
