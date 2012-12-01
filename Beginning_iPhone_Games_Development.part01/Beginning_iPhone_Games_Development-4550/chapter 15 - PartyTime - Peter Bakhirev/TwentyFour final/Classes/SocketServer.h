//
//  Server.h
//  TwentyFour
//

#import <Foundation/Foundation.h>

@class Connection;

@protocol SocketServerDelegate
- (void)socketServerStarted;
- (void)socketServerDidNotStart;
- (void)newClientConnected:(Connection*)connection;
@end

@interface SocketServer : NSObject {
  CFSocketRef listeningSocket;
  uint16_t listeningPort;
  NSNetService *netService;
  NSString *serverName;
  id<SocketServerDelegate> delegate;
  BOOL serverStarted;
}

@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, retain) id<SocketServerDelegate> delegate;

- (BOOL)start;
- (void)stop;

@end
