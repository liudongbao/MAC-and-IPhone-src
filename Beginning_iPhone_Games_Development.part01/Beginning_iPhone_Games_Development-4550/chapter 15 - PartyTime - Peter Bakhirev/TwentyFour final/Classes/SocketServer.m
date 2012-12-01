//
//  Server.m
//  TwentyFour
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

#import "SocketServer.h"
#import "Connection.h"


@implementation SocketServer

@synthesize serverName, netService;
@synthesize delegate;

static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type,
    CFDataRef address, const void *data, void *info) {
  SocketServer *server = (SocketServer*)info;
  
  // We can only process "connection accepted" calls here
  if ( type != kCFSocketAcceptCallBack ) {
    return;
  }
  
  // for AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
  CFSocketNativeHandle handle = *(CFSocketNativeHandle*)data;
  Connection *connection = [[[Connection alloc]
      initWithNativeSocketHandle:handle] autorelease];

  if ( [connection connect] ) {
    [server.delegate newClientConnected:connection];
  }
}

- (BOOL)createServer {
  //// PART 1: Create a socket that can accept connections
  CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};

  listeningSocket = CFSocketCreate(
    kCFAllocatorDefault,
    PF_INET,        // The protocol family for the socket
    SOCK_STREAM,    // The socket type to create
    IPPROTO_TCP,    // The protocol for the socket. TCP in our case.
    kCFSocketAcceptCallBack,
    (CFSocketCallBack)&serverAcceptCallback,
    &socketCtxt );
   
  // Previous call might have failed
  if ( listeningSocket == NULL ) {
    return NO;
  }

  // getsockopt will return existing socket option value via this variable
  int existingValue = 1;

  // Make sure that same listening socket address gets reused after every connection
  setsockopt( CFSocketGetNative(listeningSocket),
    SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue,
    sizeof(existingValue));

  //// PART 2: Bind our socket to an endpoint.
  // We will be listening on all available interfaces/addresses.
  // Port will be assigned automatically by kernel.
  struct sockaddr_in socketAddress;
  memset(&socketAddress, 0, sizeof(socketAddress));
  socketAddress.sin_len = sizeof(socketAddress);
  socketAddress.sin_family = AF_INET;
  socketAddress.sin_port = 0;
  socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
  
  // Convert the endpoint data structure into something that CFSocket can use
  NSData *socketAddressData =
    [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
  
  // Bind our socket to the endpoint. Check if successful.
  if ( CFSocketSetAddress(listeningSocket,
      (CFDataRef)socketAddressData) != kCFSocketSuccess ) {
    // Cleanup
    if ( listeningSocket != NULL ) {
      CFRelease(listeningSocket);
      listeningSocket = NULL;
    }
    
    return NO;
  }
  
  //// PART 3: Find out what port kernel assigned to our socket
  // We need it to advertise our service via Bonjour
  NSData *socketAddressActualData = 
      [(NSData *)CFSocketCopyAddress(listeningSocket) autorelease];

  // Convert socket data into a usable structure
  struct sockaddr_in socketAddressActual;
  memcpy(&socketAddressActual, [socketAddressActualData bytes],
      [socketAddressActualData length]);
      
  listeningPort = ntohs(socketAddressActual.sin_port);
  
  CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
  CFRunLoopSourceRef runLoopSource =
      CFSocketCreateRunLoopSource(kCFAllocatorDefault, listeningSocket, 0);
  CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
  CFRelease(runLoopSource);
  
  return YES;
}

- (BOOL)publishService {
  // Create new NetService
  self.netService = [[NSNetService alloc]
      initWithDomain:@"" type:@"_twentyfour._tcp."
      name:serverName port:listeningPort];

  if (self.netService == nil)
    return NO;

  // Add service to the current run loop
  [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop]
    forMode:NSRunLoopCommonModes];

  // NetService will let us know about what's happening via delegate methods
  [self.netService setDelegate:self];
  
  // Publish the service
  [self.netService publish];
  
  return YES;
}

- (void)netServiceDidPublish:(NSNetService*)sender {
  if ( sender != self.netService ) {
    return;
  }

  if ( serverStarted ) {
    return;
  }

  serverStarted = YES;

  [delegate socketServerStarted];
}

- (void)terminateServer {
  if ( listeningSocket != nil ) {
    CFSocketInvalidate(listeningSocket);
    CFRelease(listeningSocket);
    listeningSocket = nil;
    listeningPort = 0;
  }
}

- (void) unpublishService {
  if ( self.netService ) {
     [self.netService stop];
     [self.netService removeFromRunLoop:[NSRunLoop currentRunLoop]
         forMode:NSRunLoopCommonModes];
     self.netService = nil;
  }
}

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void)netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict {
  if ( sender != self.netService ) {
    return;
  }
  
  // Stop socket server
  [self terminateServer];
  
  // Stop Bonjour
  [self unpublishService];
  
  // Let delegate know about failure
  [delegate socketServerDidNotStart];
}

- (BOOL)start {
  if ( ! [self createServer] ) {
    return NO;
  }
  
  if ( ! [self publishService] ) {
    [self terminateServer];
    return NO;
  }
  
  return YES;
}

- (void)stop {
  serverStarted = NO;
  [self terminateServer];
  [self unpublishService];
}

- (void)dealloc {
  self.netService = nil;
  self.serverName = nil;
  self.delegate = nil;
  
  [super dealloc];
}

@end
