//
//  GameControllerServer.m
//  TwentyFour
//

#import "GameControllerServer.h"

@interface GameControllerServer ()
- (void)handleNewPlayer:(NSString*)name connection:(Connection*)connection;
- (void)startNewGameRound;
- (void)checkIfRoundShouldStop;
- (void)handleResultSuccess:(Connection*)connection seconds:(NSNumber*)seconds;
- (void)handleResultFailure:(Connection*)connection reason:(NSString*)reason;
- (void)tabulateResults;
- (void)broadcastMessage:(NSDictionary*)message;
@end

@implementation GameControllerServer

@synthesize challenge, timeRoundStarted, myPlayer;

- (void)startWithPlayerName:(NSString*)name {
  connections = [[NSMutableSet alloc] init];
  connectedPlayers = [[NSMutableSet alloc] init];

  Player *player = [[Player alloc] init];
  player.name = name;
  self.myPlayer = player;
  [connectedPlayers addObject:player];
  [player release];

  // Create server
  server = [[SocketServer alloc] init];
  server.serverName = [NSString stringWithFormat:@"%@'s game", name];
  server.delegate = self;

  if ( ! [server start] ) {
    [self socketServerDidNotStart];
  }
}

- (void)socketServerStarted {
  [delegate gameControllerStarted];
  
  // Start new game round
  [self startNewGameRound];
}

- (void)socketServerDidNotStart {
  [delegate gameControllerDidNotStart];
  server.delegate = nil;
  [server release];
  server = nil;
}

- (void)newClientConnected:(Connection*)connection {
  // We don't yet have a player associated with this connection
  connection.userInfo = nil;
  connection.delegate = self;
  [connections addObject:connection];
}

- (void)connection:(Connection*)connection receivedMessage:(NSDictionary*)message {
  // Handshake?
  if ( [message objectForKey:@"handshake"] && connection.userInfo == nil ) {
    [self handleNewPlayer:[message objectForKey:@"handshake"]
        connection:connection];
    return;
  }
  
  // Somebody submitting a result?
  if ( [message objectForKey:@"resultSuccess"] ) {
    [self handleResultSuccess:connection
        seconds:[message objectForKey:@"resultSuccess"]];
    return;
  }
  
  if ( [message objectForKey:@"resultFailure"] ) {
    [self handleResultFailure:connection
        reason:[message objectForKey:@"resultFailure"]];
    return;
  }
}

- (void)handleNewPlayer:(NSString*)name connection:(Connection*)connection {
  // Create a player object
  Player *player = [[Player alloc] init];
  player.name = name;
  [player setDidntAnswerLastRound];

  // Figure out if we can let them participate in current round
  float timeLeft = roundLength + [timeRoundStarted timeIntervalSinceNow];
  if ( isPlaying && timeLeft > 20.0 ) {
    [player startPlayingWithStatus:@"New player, guessing..."];
    
    // Tell new player to start the round
    [connection sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:
        challenge, @"startRound",
        [NSNumber numberWithFloat:timeLeft], @"time", nil]];
  }
  else {
    player.status = @"Just joined, itching to play!";
    player.isPlaying = NO;
  }
  
  // Add player into the roster
  connection.userInfo = player;
  [connectedPlayers addObject:player];

  // Recalculate results and update everybody
  [self tabulateResults];
  
  // Tell new player what's going on
  if ( isPlaying ) {
    [connection sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:
        @"Waiting for answers...", @"status", nil]];
  }
  else {
    [connection sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:
        @"Next round will start shortly...", @"status", nil]];
  }
}

- (void)connectionClosed:(Connection*)connection {
  // Remove any mention of this connection
  id player = connection.userInfo;
  connection.userInfo = nil;
  connection.delegate = nil;

  [connections removeObject:connection];
  
  // If this is a player, remove and retabulate results
  if ( player ) {
    [connectedPlayers removeObject:player];
    [player release];
    [self tabulateResults];
    [self checkIfRoundShouldStop];
  }
}

- (void)startNewGameRound {
  isPlaying = YES;
  roundLength = 100.0;
  self.timeRoundStarted = [NSDate date];
  self.challenge = [self makeNewChallenge];

  // All players are now guessing
  [connectedPlayers makeObjectsPerformSelector:
      @selector(startPlayingWithStatus:) withObject:@"Still guessing..."];

  // Tell all connected clients to start playing
  [self broadcastMessage:[NSDictionary dictionaryWithObjectsAndKeys:
      challenge, @"startRound",
      [NSNumber numberWithFloat:roundLength], @"time",
      @"Waiting for answers...", @"status", nil]];

  // Display locally
  [delegate startRoundWithChallenge:challenge secondsToPlay:roundLength];
  [delegate updateGameStatus:@"Waiting for answers..."];

  [self tabulateResults];
  
  // Make sure to stop the round after appropriate time
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }
  self.nextRoundTimer = [NSTimer scheduledTimerWithTimeInterval:roundLength+2.0
      target:self selector:@selector(stopGameRound) userInfo:nil repeats:NO];
}

- (void)checkIfRoundShouldStop {
  // Only do this while playing
  if ( !isPlaying ) {
    return;
  }
  
  // If nobody is playing anymore, stop the round
  NSEnumerator *enumerator = [connectedPlayers objectEnumerator];
  Player *player;
 
  while ((player = (Player*)[enumerator nextObject])) {
    if ( player.isPlaying ) {
      return;
    }
  }
  
  // Everybody submitted their answers, time to end the round
  isPlaying = NO;

  // Make the timer fire immediately, without waiting
  [nextRoundTimer setFireDate:[NSDate date]];  
}

- (void)stopGameRound {
  // Tell everybody that next round will start soon
  [self broadcastMessage:[NSDictionary dictionaryWithObjectsAndKeys:
      @"Next round will start shortly...", @"status", nil]];

  [delegate updateGameStatus:@"Next round will start shortly..."];

  // Schedule next round to start soon
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }
  self.nextRoundTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
      target:self selector:@selector(startNewGameRound) userInfo:nil repeats:NO];
}

- (void)stop {
  if ( nextRoundTimer ) {
    [nextRoundTimer invalidate];
  }

  // Stop server
  server.delegate = nil;
  [server stop];

  // Disconnect everybody
  [connections makeObjectsPerformSelector:@selector(close)];
  [connections release];
  connections = nil;  
}

- (void)handleResultSuccess:(Connection*)connection seconds:(NSNumber*)seconds {
  // Is this a known player?
  Player *player = connection.userInfo;
  if ( player ) {
    player.lastResult = [seconds floatValue];
    player.isPlaying = NO;

    // Recalculate results after current message processing has completed
    [self tabulateResults];
    [self checkIfRoundShouldStop];
  }  
}

- (void)handleResultFailure:(Connection*)connection reason:(NSString*)reason {
  // Is this a known player?
  Player *player = connection.userInfo;
  if ( player ) {
    [player setDidntAnswerLastRound];
    player.status = reason;
    player.isPlaying = NO;

    // Recalculate results after current message processing has completed
    [self tabulateResults];
    [self checkIfRoundShouldStop];
  }
}

- (void)submitResultSuccess:(float)seconds {
  // Record it locally
  myPlayer.lastResult = seconds;
  myPlayer.isPlaying = NO;
  
  // Send it over to everybody
  [self tabulateResults];
  [self checkIfRoundShouldStop];
}

- (void)submitResultFailure:(NSString*)reason {
  // Record it locally
  [myPlayer setDidntAnswerLastRound];
  myPlayer.status = reason;
  myPlayer.isPlaying = NO;
  
  // Send it over to everybody
  [self tabulateResults];
  [self checkIfRoundShouldStop];
}

- (void)tabulateResults {
  // Make a sorted results array
  NSArray *results = [[connectedPlayers allObjects]
      sortedArrayUsingSelector:@selector(compare:)];

  NSMutableArray *textResults = [NSMutableArray arrayWithCapacity:[results count]];
  for( int ndx = 0; ndx < [results count]; ndx++ ) {
    Player *p = [results objectAtIndex:ndx];
    [textResults addObject:[p describeResult]];
  }
  
  // Send it out
  [self broadcastMessage:[NSDictionary dictionaryWithObjectsAndKeys:
      textResults, @"results", nil]];

  // Update locally
  [delegate updateGameResults:textResults];
}

- (void)broadcastMessage:(NSDictionary*)message {
  [connections makeObjectsPerformSelector:
      @selector(sendMessage:) withObject:message];
}

- (void)dealloc {
  server.delegate = nil;
  [server release];
  
  [connections release];
  [connectedPlayers release];
  self.myPlayer = nil;
  self.timeRoundStarted = nil;
  self.challenge = nil;
  
  [super dealloc];
}

@end
