//
//  Connection.h
//  TwentyFour
//

#import <Foundation/Foundation.h>

@class Connection;

@protocol ConnectionDelegate
- (void)connectionClosed:(Connection*)connection;
- (void)connection:(Connection*)connection receivedMessage:(NSDictionary*)message;
@end

@interface Connection : NSObject {
  // Input stream
  NSInputStream *inputStream;
  NSMutableData *incomingDataBuffer;
  int nextMessageSize;

  // Output stream
  BOOL outputStreamWasOpened;
  NSOutputStream *outputStream;
  NSMutableData *outgoingDataBuffer;
  
  // Delegate
  id<ConnectionDelegate> delegate;
  
  // Extra info
  id userInfo;
}

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) id<ConnectionDelegate> delegate;
@property (nonatomic, retain) id userInfo;

// Initialize using a native socket handle, assuming connection is open
- (id)initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle;

// Initialize using a pair of streams created elsewhere
- (id)initWithInputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr;

// Connect using whatever connection info that was passed during initialization
- (BOOL)connect;

// Close connection
- (void)close;

// Send network message
- (void)sendMessage:(NSDictionary*)message;

@end
