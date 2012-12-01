//
//  HelloWorldLayer.h
//  DragDrop
//
//  Created by Ray Wenderlich on 11/15/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
    CCSprite * background;
    CCSprite * selSprite;
    NSMutableArray * movableSprites;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
