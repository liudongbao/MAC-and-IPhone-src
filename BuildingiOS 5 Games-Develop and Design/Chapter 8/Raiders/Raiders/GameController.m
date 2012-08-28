//
//  GameController.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "GameController.h"
#import "SynthesizeSingleton.h"
#import "AbstractSceneController.h"
#import "MenuSceneController.h"
#import "Level1SceneController.h"

@interface GameController (private)

- (void)initScene;

@end

@implementation GameController

@synthesize currentScene;
@synthesize currentLives;
@synthesize currentScore;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (id)init {
    self = [super init];
    if(self != nil) {
		// Initialize the game
		currentScene = nil;
        [self initScene];
        currentLives = 3;
        currentScore = 0;
    }
    return self;
}

- (void)playCurrentScene {
    [currentScene playScene];
}

- (void)updateWorld {
    [currentScene updateScene];
}

- (void)changeScene:(NSString *)scene {
    self.currentScene = [sceneList objectForKey:scene];
    [self.currentScene initScene];
    [self playCurrentScene];
}

#pragma mark -
#pragma mark Private Methods
- (void)initScene {
    AbstractSceneController *menuScene = [[MenuSceneController alloc] init];
    self.currentScene = menuScene;
    [self.currentScene initScene];
    if (sceneList == nil)
        sceneList = [NSMutableDictionary dictionary];
    
    [sceneList setValue:menuScene forKey:MENU_SCENE];
    AbstractSceneController *level1Scene = [[Level1SceneController alloc] init];
    [sceneList setValue:level1Scene forKey:LEVEL1_SCENE];
}



@end
