//
//  HelloWorldLayer.h
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/19/12.
//  Copyright WhiteWidget Inc. 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PolygonSprite.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    
    CCArray *_cache;
}

@property(nonatomic,retain)CCArray *cache;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
