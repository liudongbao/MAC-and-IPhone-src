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

@interface PinballTableLayer : CCLayer
{
	b2World* world;
    ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
}

+(CCScene*) scene;
@end
