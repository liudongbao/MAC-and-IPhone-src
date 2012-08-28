//
//  MenuSceneController.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
#import "AbstractSceneController.h"
#import <GameKit/GKLeaderboardViewController.h>
#import <GameKit/GKAchievementViewController.h>

@class Sprite;
@class ActionItem;

@interface MenuSceneController : AbstractSceneController<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    Sprite *background;
    ActionItem *showLeaderBoard;
    ActionItem *showAchievements;
}

@property (nonatomic, retain) ActionItem *playButton;

@end
