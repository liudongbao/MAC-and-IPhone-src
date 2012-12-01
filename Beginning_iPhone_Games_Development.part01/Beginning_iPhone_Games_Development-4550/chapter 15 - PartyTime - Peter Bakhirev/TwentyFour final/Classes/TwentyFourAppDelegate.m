//
//  TwentyFourAppDelegate.m
//  TwentyFour
//

#import "TwentyFourAppDelegate.h"
#import "TwentyFourViewController.h"
#import "WelcomeViewController.h"
#import "LobbyViewController.h"
#import "ResultsViewController.h"
#import "WaitingViewController.h"
#import "GameControllerServer.h"
#import "GameControllerClient.h"

@implementation TwentyFourAppDelegate

@synthesize window;
@synthesize playerName;
@synthesize tfViewController, welcomeViewController, lobbyViewController;
@synthesize resultsViewController, waitingViewController;

- (void)submitResultFailure:(NSString*)reason {
  [gameController submitResultFailure:reason];
}

- (void)submitResultSuccess:(float)seconds {
  [gameController submitResultSuccess:seconds];
}

- (void)startRoundWithChallenge:(NSArray*)challenge secondsToPlay:(float)seconds {
  [tfViewController startRoundWithChallenge:challenge secondsToPlay:seconds];

  // Show game view
  [window addSubview:tfViewController.view];
  [resultsViewController.view removeFromSuperview];
}

- (void)updateGameStatus:(NSString*)status {
  resultsViewController.labelStatus.text = status;
}

- (void)updateGameResults:(NSArray*)results {
  resultsViewController.results = results;
  [resultsViewController.tableResults reloadData];
}

- (void)playerNameEntered:(NSString*)name {
  self.playerName = name;
  
  // Show lobby
  [window addSubview:lobbyViewController.view];
  
  // Hide welcome screen
  [welcomeViewController.view removeFromSuperview];
}

- (void)showWaitingScreen {
  [window addSubview:waitingViewController.view];
  [window bringSubviewToFront:waitingViewController.view];
}

- (void)hideWaitingScreen {
  [waitingViewController.view removeFromSuperview];
}

- (void)startNewGame {
  [self showWaitingScreen];

  GameControllerServer *game = [[GameControllerServer alloc] init];
  game.delegate = self;
  [game startWithPlayerName:playerName];
  
  gameController = game;
}

- (void)connectToGame:(Connection*)connection {
  [self showWaitingScreen];
  
  GameControllerClient *game = [[GameControllerClient alloc] init];
  game.delegate = self;
  [game startWithConnection:connection playerName:playerName];
  
  gameController = game;
}

- (void)gameControllerStarted {
  [self hideWaitingScreen];
  
  // Hide lobby view
  [lobbyViewController.view removeFromSuperview];
}

- (void)gameControllerDidNotStart {
  [self hideWaitingScreen];

  [gameController release];
  gameController = nil;

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
      message:@"Could not start/join game." delegate:nil cancelButtonTitle:@"Ok"
      otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)exitGame {
  [gameController stop];
  gameController.delegate = nil;
  [gameController release];
  gameController = nil;

  // Show lobby
  [window addSubview:lobbyViewController.view];

  // Hide game view
  [tfViewController.view removeFromSuperview];
}

- (void)showGameResultsScreen {
  // Show results view
  [window addSubview:resultsViewController.view];
  
  // Hide game view
  [tfViewController.view removeFromSuperview];
}

- (void)gameControllerTerminated {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
      message:@"Game has been terminated." delegate:nil cancelButtonTitle:@"Ok"
      otherButtonTitles:nil];
  [alert show];
  [alert release];

  [gameController release];
  gameController = nil;

  // Show lobby
  [window addSubview:lobbyViewController.view];

  // Hide game view
  [tfViewController stopRound];
  [tfViewController.view removeFromSuperview]; 
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {        
  // Override point for customization after app launch
  sranddev();
  [window addSubview:welcomeViewController.view];
  [window makeKeyAndVisible];
}

+ (TwentyFourAppDelegate*)getInstance {
  return (TwentyFourAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)dealloc {
  [tfViewController release];
  [welcomeViewController release];
  [lobbyViewController release];
  [resultsViewController release];
  [waitingViewController release];
  [gameController release];
  self.playerName = nil;
  [window release];
  [super dealloc];
}

@end
