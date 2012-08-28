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

@interface GameController (private)

- (void)initScene;

@end

@implementation GameController

@synthesize currentScene;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (id)init {
    self = [super init];
    if(self != nil) {
		// Initialize the game
		currentScene = nil;
        [self initScene];
    }
    return self;
}

- (void)playCurrentScene {
    [currentScene playScene];
}

- (void)updateWorld {
    [currentScene updateScene];
}

#pragma mark -
#pragma mark Private Methods
- (void)initScene {
    AbstractSceneController *menuScene = [[MenuSceneController alloc] init];
    self.currentScene = menuScene;
}



@end
