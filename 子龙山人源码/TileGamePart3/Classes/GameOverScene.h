//
//  GameOverLoseScene.h
//  bcamcocos2dtutorial1
//
//  Created by bcam2 on 6/9/10.
//  Copyright 2010 Geek And Dad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
 
@interface GameOverLayer : CCColorLayer {
  CCLabel *_label;
}
@property (nonatomic, retain) CCLabel *label;
@end
 
@interface GameOverScene : CCScene {
  GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end