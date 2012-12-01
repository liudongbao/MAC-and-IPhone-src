//
//  GameControllerClient.m
//  TwentyFour
//

#import "GameControllerClient.h"


@implementation GameControllerClient

@synthesize gameServerConnection;

- (void)startWithConnection:(Connection*)connection playerName:(NSString*)name {
  self.playerName = name;
  self.gameServerConnection = connection;
  
  gameServerConnection.delegate = self;

  if ( ! [gameServerConnection connect] ) {
    self.gameServerConnection = nil;
    [delegate gameControllerDidNotStart];
    return;
  }

  // We will be fully connected after the handshake goes through
  isFullyConnected = NO;
  
  // Introduce ourselves to the server
  [gameServerConnection sendMessage:
      [NSDictionary dictionaryWithObjectsAndKeys:playerName, @"handshake", nil]];
}

- (void)submitResultSuccess:(float)seconds {
  // Tell the server that we are done
  [gameServerConnection sendMessage:
      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:seconds],
      @"resultSuccess", nil]];
}

- (void)submitResultFailure:(NSString*)reason {
  // Tell the server that we are done
  [gameServerConnection sendMessage:
      [NSDictionary dictionaryWithObjectsAndKeys:reason, @"resultFailure", nil]];
}

- (void)connection:(Connection*)connection receivedMessage:(NSDictionary*)message {
  // Results update?
  if ( [message objectForKey:@"results"] ) {
    [delegate updateGameResults:[message objectForKey:@"results"]];

    // If it's the first thing after handshake, show the screen
    if ( !isFullyConnected ) {
      [delegate gameControllerStarted];
      [delegate showGameResultsScreen];
      isFullyConnected = YES;
    }
  }

  // Game round starts?
  if ( [message objectForKey:@"startRound"] ) {
    if ( !isFullyConnected ) {
      [delegate gameControllerStarted];
      isFullyConnected = YES;
    }

    [delegate startRoundWithChallenge:[message objectForKey:@"startRound"]
        secondsToPlay:[[message objectForKey:@"time"] floatValue]];        
  }
  
  // Status update?
  if ( [message objectForKey:@"status"] ) {
    [delegate updateGameStatus:[message objectForKey:@"status"]];
  }
}

- (void)stop {
  if ( !isFullyConnected ) {
    [delegate gameControllerDidNotStart];
  }

  [gameServerConnection close];
  gameServerConnection.delegate = nil;
  isFullyConnected = NO;
}

- (void)connectionClosed:(Connection*)connection {
  if ( connection != gameServerConnection ) {
    return;
  }

  // Stop the game
  if ( !isFullyConnected ) {
    [delegate gameControllerDidNotStart];
  }
  else {
    [delegate gameControllerTerminated];
  }

  gameServerConnection.delegate = nil;
  isFullyConnected = NO;
}

- (void)dealloc {
  self.gameServerConnection = nil;  
  [super dealloc];
}

@end
