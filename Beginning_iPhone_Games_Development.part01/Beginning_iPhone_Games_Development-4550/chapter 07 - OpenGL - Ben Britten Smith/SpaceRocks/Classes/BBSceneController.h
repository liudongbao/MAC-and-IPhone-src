//
//  BBSceneController.h
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBInputViewController;
@class EAGLView;
@class BBSceneObject;
@class BBCollisionController;

@interface BBSceneController : NSObject {
	NSMutableArray * sceneObjects;
	NSMutableArray * objectsToRemove;
	NSMutableArray * objectsToAdd;
	BBInputViewController * inputController;
	EAGLView * openGLView;
	BBCollisionController * collisionController;
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
}

@property (retain) BBInputViewController * inputController;
@property (retain) EAGLView * openGLView;

@property NSTimeInterval animationInterval;
@property (nonatomic, assign) NSTimer *animationTimer;

+ (BBSceneController*)sharedSceneController;
- (void) dealloc;
- (void) loadScene;
- (void) startScene;
- (void)gameLoop;
- (void)renderScene;
- (void)setAnimationInterval:(NSTimeInterval)interval ;
- (void)setAnimationTimer:(NSTimer *)newTimer ;
- (void)startAnimation ;
- (void)stopAnimation ;
- (void)updateModel;
-(void)generateRocks;
-(void)addObjectToScene:(BBSceneObject*)sceneObject;
-(void)removeObjectFromScene:(BBSceneObject*)sceneObject;
// 11 methods

@end
