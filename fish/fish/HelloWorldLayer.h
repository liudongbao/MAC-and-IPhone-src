//
//  HelloWorldLayer.h
//  fish
//
//  Created by 海锋 周 on 12-4-11.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import  "CCFish.h"
#import  "CCNet.h"
#import  "UIRollNum.h"


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCSpriteBatchNode *netSheet;
    CCSpriteBatchNode *fishSheet;
    CCSpriteBatchNode *fish2Sheet;
    CCSpriteBatchNode *cannonSheet;
    CCAction *fish01_act;
    UIRollNum *score1;
    CCSprite *gun;
    int Energy;
    int maxEnergy;
    CCSprite *engryPointer;
    
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) LoadTexture;
-(void) initUITab;
-(void) addFish;
-(void) updateGame:(ccTime)delta;
-(void) ShowNet:(id)sender;
@end
