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
//#import <Twitter/Twitter.h>
//#import <Accounts/Accounts.h>

@interface GameController (private)

- (void)initScene;

@end

@implementation GameController

@synthesize currentScene;
@synthesize currentLives;
@synthesize currentScore;
@synthesize mainView;

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

//- (void)sendTweet {
//    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
//    
//    // Set the initial tweet text. See the framework for additional properties that can be set.
//    [tweetViewController setInitialText:[NSString stringWithFormat:@"I just scored %d points in Raiders", currentScore]];
//    
//    // Create the completion handler block.
//    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
//        NSString *output;
//        
//        switch (result) {
//            case TWTweetComposeViewControllerResultCancelled:
//                // The cancel button was tapped.
//                output = @"Tweet cancelled.";
//                break;
//            case TWTweetComposeViewControllerResultDone:
//                // The tweet was sent.
//                output = @"Tweet done.";
//                break;
//            default:
//                break;
//        }
//        
//        // Dismiss the tweet composition view controller.
//        [mainView dismissModalViewControllerAnimated:YES];
//    }];
//    
//    // Present the tweet composition view controller modally.
//    [mainView presentModalViewController:tweetViewController animated:YES];
//}

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
