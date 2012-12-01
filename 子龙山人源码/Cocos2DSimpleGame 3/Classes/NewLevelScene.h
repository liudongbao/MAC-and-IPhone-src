//
//  NewLevelScene.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 3/22/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface NewLevelLayer : CCColorLayer {
}

-(void)reset;

@end

@interface NewLevelScene : CCScene {
	NewLevelLayer *_layer;
}

@property (nonatomic, retain) NewLevelLayer *layer;

@end
