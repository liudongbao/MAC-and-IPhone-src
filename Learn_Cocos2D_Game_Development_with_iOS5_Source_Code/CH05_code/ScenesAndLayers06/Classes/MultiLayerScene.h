//
//  MultiLayerScene.h
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 28.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Using an enum to define tag values has the upside that you can select
// tags by name instead of having to remember each individual number.
typedef enum
{
	LayerTagGameLayer,
	LayerTagUILayer,
} MultiLayerSceneTags;

typedef enum
{
	ActionTagGameLayerMovesBack,
	ActionTagGameLayerRotates,
} MultiLayerSceneActionTags;


// Class forwards: if a class is used in a header file only to define a member variable or return value,
// then it's more effective to use the @class keyword rather than #import the class header file.
// When projects grow large this helps to reduce the time it takes to compile the project.
@class GameLayer;
@class UserInterfaceLayer;

@interface MultiLayerScene : CCLayer 
{
	bool isTouchForUserInterface;
}

// Accessor methods to access the various layers of this scene
+(MultiLayerScene*) sharedLayer;

@property (readonly) GameLayer* gameLayer;
@property (readonly) UserInterfaceLayer* uiLayer;

+(CGPoint) locationFromTouch:(UITouch*)touch;
+(CGPoint) locationFromTouches:(NSSet *)touches;

+(id) scene;

@end
