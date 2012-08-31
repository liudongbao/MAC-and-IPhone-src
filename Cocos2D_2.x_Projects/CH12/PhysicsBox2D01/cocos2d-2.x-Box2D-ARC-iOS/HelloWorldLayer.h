//
//  HelloWorldLayer.h
//  cocos2d-2.x-Box2D-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"

// Pixel to metres ratio. Box2D uses meters as the unit for measurement.
// This ratio defines how many pixels correspond to 1 Box2D "meter"
// Box2D is optimized for objects of 1x1 meters therefore it makes sense
// to define the ratio so that your most common object type is 1x1 meter.
#define PTM_RATIO 32

#define TILESIZE 32
#define TILESET_COLUMNS 9
#define TILESET_ROWS 19

enum 
{
	kTagBatchNode,
};

@interface HelloWorldLayer : CCLayer
{
	CCTexture2D* spriteTexture;
	b2World* world;
    ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
}

+(CCScene*) scene;
@end
