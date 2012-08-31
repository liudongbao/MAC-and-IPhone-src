//
//  MultiLayerScene.m
//  ScenesAndLayers
//
//  Created by Steffen Itterheim on 28.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "MultiLayerScene.h"
#import "UserInterfaceLayer.h"
#import "GameLayer.h"

@implementation MultiLayerScene

// Semi-Singleton: you can access MultiLayerScene only as long as it is the active scene.
static MultiLayerScene* sharedMultiLayerScene = nil;

+(MultiLayerScene*) sharedLayer
{
	NSAssert(sharedMultiLayerScene != nil, @"MultiLayerScene not available!");
	return sharedMultiLayerScene;
}

// Access to the various layers by wrapping the getChildByTag method
// and checking if the received node is of the correct class.
-(GameLayer*) gameLayer
{
	CCNode* layer = [self getChildByTag:LayerTagGameLayer];
	NSAssert([layer isKindOfClass:[GameLayer class]], @"%@: not a GameLayer!", NSStringFromSelector(_cmd));
	return (GameLayer*)layer;
}

-(UserInterfaceLayer*) uiLayer
{
	CCNode* layer = [[MultiLayerScene sharedLayer] getChildByTag:LayerTagUILayer];
	NSAssert([layer isKindOfClass:[UserInterfaceLayer class]], @"%@: not a UserInterfaceLayer!", NSStringFromSelector(_cmd));
	return (UserInterfaceLayer*)layer;
}

+(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

+(CGPoint) locationFromTouches:(NSSet*)touches
{
	return [self locationFromTouch:[touches anyObject]];
}

+(id) scene
{
	CCScene* scene = [CCScene node];
	MultiLayerScene* layer = [MultiLayerScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		NSAssert(sharedMultiLayerScene == nil, @"another MultiLayerScene is already in use!");
		sharedMultiLayerScene = self;

		// This adds a colored background layer.
		CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(255, 0, 255, 255)];
		[self addChild:colorLayer];

		CCLayerGradient* gradientLayer = [CCLayerGradient layerWithColor:ccc4(0, 150, 255, 255) 
																fadingTo:ccc4(255, 150, 50, 255)
															 alongVector:CGPointMake(1.0f, 1.0f)];
		gradientLayer.position = CGPointMake(10, 10);
		gradientLayer.anchorPoint = CGPointZero;
		[gradientLayer changeWidth:460 height:300];
		[self addChild:gradientLayer];

		// The GameLayer will be moved, rotated and scaled independently from other layers.
		// It also contains a number of moving pseudo game objects to show the effect on child nodes of GameLayer.
		GameLayer* gameLayer = [GameLayer node];
		[self addChild:gameLayer z:1 tag:LayerTagGameLayer];
		
		// The UserInterfaceLayer remains static and relative to the screen area.
		UserInterfaceLayer* uiLayer = [UserInterfaceLayer node];
		[self addChild:uiLayer z:2 tag:LayerTagUILayer];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	// The Layer will be gone now, to avoid crashes on further access it needs to be nil.
	sharedMultiLayerScene = nil;
}

@end
