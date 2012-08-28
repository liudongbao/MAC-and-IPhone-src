//
//  MenuSceneController.m
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//

#import "MenuSceneController.h"
#import "Sprite.h"
#import "GameController.h"
#import "ActionItem.h"

#import <GameKit/GameKit.h>

@implementation MenuSceneController

@synthesize playButton;

- (id) init
{
	self = [super init];
	if (self != nil) {

	}
	return self;
}

- (void)initScene {
    [super initScene];
    playButton = [[ActionItem alloc] initWithImageNamed:@"play"];
    background = [[Sprite alloc] initWithImageNamed:@"background2"];
    showLeaderBoard = [[ActionItem alloc] initWithImageNamed:@"showleaderboard.png"];
    showAchievements = [[ActionItem alloc] initWithImageNamed:@"achievements.png"];
    
    [self addSprite:playButton];
    [self addSprite:background];
    [self addSprite:showLeaderBoard];
    [self addSprite:showAchievements];
}

- (void)playScene {
    [super playScene];
    [background drawAtPosition:CGPointMake(0.0f, 0.0f)];
    [playButton drawAtPosition:CGPointMake(10.0f, 410.0f)];
    [showLeaderBoard drawAtPosition:CGPointMake(10.0f, 100.0f)];
    [showAchievements drawAtPosition:CGPointMake(10.0f, 300.0f)];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint touchPoint = [touch locationInView:aView];
    
    if ([playButton hasBeenTapped:touchPoint]) {
        [playButton tapAction:@selector(gotoLevel1Scene) target:self];
    }
    
    if ([showLeaderBoard hasBeenTapped:touchPoint]) {
        [showLeaderBoard tapAction:@selector(showLeaderBoard) target:self];
    }
    
    if ([showAchievements hasBeenTapped:touchPoint]) {
        [showAchievements tapAction:@selector(showAchievements) target:self];
    }
}

#pragma mark - ActionItem selectors

- (void)gotoLevel1Scene {
    [[GameController sharedGameController] changeScene:LEVEL1_SCENE];
}

- (void)showLeaderBoard {
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [[GameController sharedGameController].mainView presentViewController:leaderboardController animated:YES completion:nil];
        
    }
}

- (void)showAchievements {
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil) {
        achievements.achievementDelegate = self;
        [[GameController sharedGameController].mainView presentModalViewController:achievements animated:YES];
    }
}

#pragma mark - Leaderboard delegate

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [[GameController sharedGameController].mainView dismissModalViewControllerAnimated:YES];
}

#pragma mark - Achievements Controller

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [[GameController sharedGameController].mainView dismissModalViewControllerAnimated:YES];
}

@end
