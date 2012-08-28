//
//  GameController.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
#import <GLKit/GLKViewController.h>

@class AbstractSceneController;

@interface GameController : NSObject {
    NSDictionary *sceneList;
}

@property (nonatomic, retain) AbstractSceneController *currentScene;
@property (assign) int currentScore;
@property (assign) int currentLives;
@property (retain) GLKViewController *mainView;


+ (GameController *)sharedGameController;

- (void)playCurrentScene;
- (void)updateWorld;
- (void)changeScene:(NSString *)scene;

- (void)sendTweet;


@end
