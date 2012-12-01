//
//  Monster.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 3/22/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface Monster : CCSprite {
    int _curHp;
    int _minMoveDuration;
    int _maxMoveDuration;
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;

@end

@interface WeakAndFastMonster : Monster {
}
+(id)monster;
@end

@interface StrongAndSlowMonster : Monster {
}
+(id)monster;
@end