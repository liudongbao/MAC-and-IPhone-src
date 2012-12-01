//
//  Connection.m
//  TwentyFour
//

#import "Connection.h"
#import <CFNetwork/CFSocketStream.h>


@implementation Connection

@synthesize delegate, userInfo;
@synthesize inputStream, outputStream;

- (id)initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle {
  CFReadStreamRef readStream;
  CFWriteStreamRef writeStream;
  
  // Bind read/write streams to the socket represented by a native socket handle
  CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
      &readStream, &writeStream);
  
  self.inputStream = (NSInputStream*)readStream;
  self.outputStream = (NSOutputStream*)writeStream;

  return self;
}

- (id)initWithInputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr {
  self.inputStream = istr;
  self.outputStream = ostr;

  return self;
}

- (BOOL)connect {
  // Make sure we have streams
  if ( !inputStream || !outputStream ) {
    return NO;
  }
  
  // Create data buffers
  incomingDataBuffer = [[NSMutableData alloc] init];
  outgoingDataBuffer = [[NSMutableData alloc] init];

  // Socket should be closed when streams are closed
  CFReadStreamSetProperty((CFReadStreamRef)inputStream,
      kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
  CFWriteStreamSetProperty((CFWriteStreamRef)outputStream,
      kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
  
  // Set delegate and schedule streams in run loop
  inputStream.delegate = self;
  [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
      forMode:NSDefaultRunLoopMode];
      
  outputStream.delegate = self;
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
      forMode:NSDefaultRunLoopMode];

  outputStreamWasOpened = NO;
  nextMessageSize = -1;

  // Open
  [inputStream open];
  [outputStream open];
  
  return YES;
}

- (void)close {
  [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
      forMode:NSDefaultRunLoopMode];
  [inputStream close];
  inputStream.delegate = nil;
  
  [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
      forMode:NSDefaultRunLoopMode];
  [outputStream close];
  outputStream.delegate = nil;
}

- (void)dealloc {
  self.delegate = nil;
  self.userInfo = nil;  
  inputStream.delegate = nil;
  self.inputStream = nil;
  outputStream.delegate = nil;
  self.outputStream = nil;
  
  [incomingDataBuffer release];
  [outgoingDataBuffer release];
  
  [super dealloc];
}

- (void)processIncomingData:(NSData*)data {
  NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  
  // Tell our delegate about it
  [delegate connection:self receivedMessage:message];
}

// Read as many bytes from the stream as possible and try to extract messages
- (void)readFromStreamIntoIncomingBuffer {
  // Temporary buffer to read data into
  uint8_t buf[1024];

  // Try reading while there is data
  while( [inputStream hasBytesAvailable] ) {
    NSInteger bytesRead = [inputStream read:buf maxLength:sizeof(buf)];
    if ( bytesRead > 0 ) {
      [incomingDataBuffer appendBytes:buf length:bytesRead];
    }
    else {
      // Error or data exhausted?
      if ( [inputStream streamStatus] == NSStreamStatusAtEnd ) {
        // No more data
        break;
      }
      else {
        [self close];
        [delegate connectionClosed:self];
        return;
      }
    }
  }

  // Try to extract messages from the buffer.
  // We might have more than one message in the buffer,
  // that's why we'll be reading it inside the while loop
  while( YES ) {
    // Did we read the header yet?
    if ( nextMessageSize == -1 ) {
      // Do we have enough bytes in the buffer to read the header?
      if ( [incomingDataBuffer length] >= sizeof(int) ) {
        // extract length
        memcpy(&nextMessageSize, [incomingDataBuffer bytes], sizeof(int));
        
        // remove that chunk from buffer
        NSRange r = {0, sizeof(int)};
        [incomingDataBuffer replaceBytesInRange:r withBytes:nil length:0];
      }
      else {
        // We don't have enough yet. Will wait for more data.
        break;
      }
    }
    
    // We should now have the header. Time to extract the body.
    if ( [incomingDataBuffer length] >= nextMessageSize ) {
      // We now have enough data to extract a meaningful message.
      NSData* raw = [NSData dataWithBytes:[incomingDataBuffer bytes]
          length:nextMessageSize];

      [self processIncomingData:raw];

      // Remove that chunk from buffer
      NSRange r = {0, nextMessageSize};
      [incomingDataBuffer replaceBytesInRange:r withBytes:NULL length:0];
      
      // We have processed the message. Resetting state.
      nextMessageSize = -1;
    }
    else {
      // Not enough data yet. Will wait.
      break;
    }
  }
}

// Write whatever data we have, as much of it as stream can handle
- (void)writeOutgoingBufferToStream {
  // Do we have anything to write?
  if ( [outgoingDataBuffer length] == 0 || !outputStreamWasOpened ) {
    return;
  }

  if ( ! [outputStream hasSpaceAvailable] ) {
    return;
  }

  // Write as much as we can
  NSInteger bytesWritten = [outputStream write:[outgoingDataBuffer bytes]
      maxLength:[outgoingDataBuffer length]];

  if ( bytesWritten == -1 ) {
    if ( [outputStream streamStatus] == NSStreamStatusClosed ||
       [outputStream streamStatus] == NSStreamStatusError ) {
      // Error occurred. Close everything up.
      [self close];
      [delegate connectionClosed:self];
    }

    return;
  }
  
  NSRange r = {0, bytesWritten};
  [outgoingDataBuffer replaceBytesInRange:r withBytes:nil length:0];
}

- (void)sendMessage:(NSDictionary*)message {
  // Encode message
  NSData* rawMessage = [NSKeyedArchiver archivedDataWithRootObject:message];
  
  // Write header: lengh of raw message
  int messageLength = [rawMessage length];
  [outgoingDataBuffer appendBytes:&messageLength length:sizeof(int)];
  
  // Write body: encoded NSDictionary
  [outgoingDataBuffer appendData:rawMessage];
  
  // Try to write to stream
  [self writeOutgoingBufferToStream];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
  if ( theStream == inputStream && streamEvent & NSStreamEventHasBytesAvailable ) {
    [self readFromStreamIntoIncomingBuffer];
  }

  if ( theStream == outputStream && streamEvent & NSStreamEventHasSpaceAvailable ) {
    [self writeOutgoingBufferToStream];
  }

  if ( theStream == outputStream && streamEvent & NSStreamEventOpenCompleted ) {
    outputStreamWasOpened = YES;
    [self writeOutgoingBufferToStream];
  }

  // Connection closed or error - treat it as "we are done"
  if ( streamEvent & (NSStreamEventErrorOccurred|NSStreamEventEndEncountered)) {
    [self close];
    [delegate connectionClosed:self];
  }
}

@end
