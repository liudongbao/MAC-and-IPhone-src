//
//  TwentyFourAppDelegate.h
//  TwentyFour
//

#import <UIKit/UIKit.h>
#import "GameController.h"

@class TwentyFourViewController;
@class WelcomeViewController;
@class LobbyViewController;
@class ResultsViewController;
@class WaitingViewController;


@interface TwentyFourAppDelegate : NSObject <UIApplicationDelegate,
    GameControllerDelegate> {
  UIWindow *window;
  NSString* playerName;
  TwentyFourViewController *tfViewController;
  WelcomeViewController *welcomeViewController;
  LobbyViewController *lobbyViewController;
  ResultsViewController *resultsViewController;
  WaitingViewController *waitingViewController;

  GameController *gameController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *playerName;
@property (nonatomic, retain) IBOutlet TwentyFourViewController *tfViewController;
@property (nonatomic, retain) IBOutlet WelcomeViewController *welcomeViewController;
@property (nonatomic, retain) IBOutlet LobbyViewController *lobbyViewController;
@property (nonatomic, retain) IBOutlet ResultsViewController *resultsViewController;
@property (nonatomic, retain) IBOutlet WaitingViewController *waitingViewController;

+ (TwentyFourAppDelegate*)getInstance;
- (void)playerNameEntered:(NSString*)name;
- (void)startNewGame;
- (void)submitResultFailure:(NSString*)reason;
- (void)submitResultSuccess:(float)seconds;
- (void)exitGame;
- (void)showWaitingScreen;
- (void)hideWaitingScreen;

@end