//
//  GameController.m
//  TwentyFour
//

#import "GameController.h"


@implementation GameController

@synthesize delegate, nextRoundTimer, playerName;

- (NSMutableArray*)makeNewChallenge {
  NSMutableArray *challenge = [NSMutableArray arrayWithCapacity:4];

  for( int i = 0; i < 4; i++ ) {
    float n = rand() % 9 + 1;
    [challenge addObject:[NSNumber numberWithFloat:n]];
  }

  return challenge;
}

- (void)submitResultSuccess:(float)seconds {
  NSArray* results = [NSArray arrayWithObject:
      [NSString stringWithFormat:@"%@: %.2f seconds", playerName, seconds]];
      
  [delegate updateGameResults:results];

  // No need to wait until all 100 seconds elapse. Game is over already.
  [nextRoundTimer setFireDate:[NSDate date]];
}

- (void)submitResultFailure:(NSString*)reason {
  NSArray* results = [NSArray arrayWithObject:
      [NSString stringWithFormat:@"%@: %@", playerName, reason]];

  [delegate updateGameResults:results];

  // No need to wait until all 100 seconds elapse. Game is over already.
  [nextRoundTimer setFireDate:[NSDate date]];
}

- (void)startNewGameRound {
  // Kick off the game
  [delegate startRoundWithChallenge:[self makeNewChallenge] secondsToPlay:100.0];

  // Make sure to stop the round after appropriate time
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }
  self.nextRoundTimer = [NSTimer scheduledTimerWithTimeInterval:100.0
      target:self selector:@selector(stopGameRound) userInfo:nil repeats:NO];  
}

- (void)stopGameRound {
  [delegate updateGameStatus:@"Next round will start shortly..."];

  // Schedule next round to start soon
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }
  self.nextRoundTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
      target:self selector:@selector(startNewGameRound) userInfo:nil repeats:NO];
}

- (void)startWithPlayerName:(NSString*)name {
  self.playerName = name;
  [delegate gameControllerStarted];
  [self startNewGameRound];
}

- (void)stop {
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }
}

- (void)dealloc {
  self.delegate = nil;
  self.nextRoundTimer = nil;
  self.playerName = nil;
  
  [super dealloc];
}

@end
