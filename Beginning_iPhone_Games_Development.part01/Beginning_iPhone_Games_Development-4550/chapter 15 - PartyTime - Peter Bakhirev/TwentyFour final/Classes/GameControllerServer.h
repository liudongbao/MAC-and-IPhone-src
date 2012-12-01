//
//  GameControllerServer.h
//  TwentyFour
//

#import <Foundation/Foundation.h>
#import "GameController.h"
#import "SocketServer.h"
#import "Player.h"
#import "Connection.h"


@interface GameControllerServer : GameController <SocketServerDelegate,
    ConnectionDelegate> {
  SocketServer *server;

  NSMutableSet *connections;
  NSMutableSet *connectedPlayers;
  Player *myPlayer;

  NSTimeInterval roundLength;
  NSDate *timeRoundStarted;
  NSMutableArray *challenge;
  BOOL isPlaying;
}

@property (nonatomic, retain) NSMutableArray *challenge;
@property (nonatomic, retain) NSDate *timeRoundStarted;
@property (nonatomic, retain) Player *myPlayer;

@end
