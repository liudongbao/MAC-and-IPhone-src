//
//  GameControllerClient.h
//  TwentyFour
//

#import <Foundation/Foundation.h>
#import "GameController.h"
#import "Connection.h"


@interface GameControllerClient : GameController <ConnectionDelegate> {
  Connection *gameServerConnection;
  BOOL isFullyConnected;
}

@property (nonatomic, retain) Connection *gameServerConnection;

- (void)startWithConnection:(Connection*)connection playerName:(NSString*)name;

@end
