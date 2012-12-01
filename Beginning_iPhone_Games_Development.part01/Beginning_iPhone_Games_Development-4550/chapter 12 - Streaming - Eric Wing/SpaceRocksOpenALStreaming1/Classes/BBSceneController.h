//
//  BBSceneController.h
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenALSoundController.h"

@class BBInputViewController;
@class EAGLView;
@class BBSceneObject;
@class BBCollisionController;
@class EWStreamBufferData;

@interface BBSceneController : NSObject <EWSoundCallbackDelegate> {
	NSMutableArray * sceneObjects;
	NSMutableArray * objectsToRemove;
	NSMutableArray * objectsToAdd;
	BBInputViewController * inputController;
	EAGLView * openGLView;
	BBCollisionController * collisionController;
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	NSTimeInterval deltaTime;
	NSTimeInterval lastFrameStartTime;
	NSTimeInterval timeSinceLevelStart;
	NSDate * levelStartTime;
	NSInteger UFOCountDown;
	BOOL needToLoadScene;
	EWStreamBufferData* backgroundMusicStreamBufferData;
	ALuint backgroundMusicSourceID;
}

@property (retain) BBInputViewController * inputController;
@property (retain) EAGLView * openGLView;
@property (retain) NSDate * levelStartTime;
@property NSTimeInterval animationInterval;
@property NSTimeInterval deltaTime;
@property (nonatomic, assign) NSTimer *animationTimer;

+ (BBSceneController*)sharedSceneController;
- (void) dealloc;
- (void) startScene;
- (void)addObjectToScene:(BBSceneObject*)sceneObject;
- (void)gameLoop;
- (void)gameOver;
- (void)generateRocks;
- (void) invokeLoadResources;
- (void)loadScene;
- (void)removeObjectFromScene:(BBSceneObject*)sceneObject;
- (void)renderScene;
- (void)restartScene;
- (void)setAnimationInterval:(NSTimeInterval)interval;
- (void)setAnimationTimer:(NSTimer *)newTimer;
- (void)startAnimation;
- (void)stopAnimation;
- (void)updateModel;
- (void)setupLighting;
// 16 methods

// For EWSoundCallbackDelegate
- (void) soundDidFinishPlaying:(NSNumber*)source_number;


@end
