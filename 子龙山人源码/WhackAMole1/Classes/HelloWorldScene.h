//
//  HelloWorldLayer.h
//  WhackAMole
//
//  Created by Ray Wenderlich on 1/5/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
    NSMutableArray *moles;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
