//
//  TicTacToeViewController.m
//  TicTacToe
//
//  Created by Swipe Interactive on 3/10/09.
//  Copyright Swipe Interactive 2009. All rights reserved.
//

#import "TicTacToeViewController.h"
#import "Cell.h"

@implementation TicTacToeViewController

@synthesize servicesTable;

#pragma mark init
- (void)viewDidLoad {
	
	myTurn = NO;
	
	// use UIView as game grid overlay for simplicity
	overlay = [[UIView alloc] initWithFrame:self.view.bounds];
	[overlay setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
	
	// set up 3x3 grid of Cells
	int i,j;
	for(j=0;j<3;j++) {
		for(i=0;i<3;i++) {
			Cell *cell = [[Cell alloc] initWithHPos:i vPos:j sender:self];
			[overlay addSubview:cell];
			[cell release];
		}
	}
	
	// set up buttons to control game status
	UIButton *endGameB = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[endGameB setTitle:@"Leave Game" forState:UIControlStateNormal];
	[endGameB setFrame:CGRectMake(10, 330, 100, 30)];
	[endGameB addTarget:self action:@selector(endGameButton) 
	   forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:endGameB];
	
	UIButton *resetGameB = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[resetGameB setTitle:@"New Game" forState:UIControlStateNormal];
	[resetGameB setFrame:CGRectMake(210, 330, 100, 30)];
	[resetGameB addTarget:self action:@selector(clearCellsButton) 
		 forControlEvents:UIControlEventTouchUpInside];
	[overlay addSubview:resetGameB];
	
	[self.view addSubview:overlay];
	
	// hide game view
	[overlay setHidden:YES];
	
	// array for keeping discovered services in
	services = [[NSMutableArray array] retain];
	
	// set up socket, service and service browser
	socketRef = [self initSocket];
	[self publishService];
	[self initServiceBrowser];
	
	[super viewDidLoad];
	
}


#pragma mark Socket setup and callBack

static void socketCallBack( CFSocketRef s, CFSocketCallBackType type,
						   CFDataRef address, const void *dataIn, void *info )
{
	TicTacToeViewController *socketController = (TicTacToeViewController *) info;
	
	if (kCFSocketAcceptCallBack == type) { 
		
		CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)dataIn;
		CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
		CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, 
									 &readStream, &writeStream);
		
		if (readStream && writeStream) {
			
			CFReadStreamSetProperty(readStream, 
									kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			CFWriteStreamSetProperty(writeStream, 
									 kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			
			[socketController 
			 didAcceptConnectionWithinputStream:(NSInputStream *)readStream
			 outputStream:(NSOutputStream *)writeStream];
			
		} else {
			
			close(nativeSocketHandle);
			
		}
		
		if (readStream) CFRelease(readStream);
		if (writeStream) CFRelease(writeStream);
		
	}
	
}

- (CFSocketRef) initSocket {
	
	CFSocketContext context = {
		.version = 0,
		.info = self,
		.retain = NULL,
		.release = NULL,
		.copyDescription = NULL
	};
	
	CFSocketRef socket = CFSocketCreate(
		kCFAllocatorDefault,
		PF_INET,
		SOCK_STREAM,
		IPPROTO_TCP,
		kCFSocketAcceptCallBack, // callBackTypes
		socketCallBack, // callBack function
		&context
	);
	
	struct sockaddr_in addr4;
	
	memset(&addr4, 0, sizeof(addr4));
	addr4.sin_family = AF_INET;
	addr4.sin_len = sizeof(addr4);
	addr4.sin_port = 0;
	addr4.sin_addr.s_addr = htonl(INADDR_ANY);
	
	int yes = 1;
	setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, 
			   (void *)&yes, sizeof(yes));
	
	NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
	CFSocketSetAddress(socket, (CFDataRef)address4);
    
	CFRunLoopSourceRef source;
	source = CFSocketCreateRunLoopSource(NULL, socket, 1);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);
	
	return socket;
	
}

#pragma mark NSNetService publisher and browser

-(void)publishService {
	// find the socket's assigned port
	NSData *addr = [(NSData *)CFSocketCopyAddress(socketRef) autorelease];
	struct sockaddr_in addr4;
	memcpy(&addr4, [addr bytes], [addr length]);
	uint16_t port = ntohs(addr4.sin_port);
	
	// set up and publish the service
	service = [[NSNetService alloc] initWithDomain:@""
											  type:@"_mygame._tcp."
											  name:@""
											  port:port];
	
	if(service) {
		
		[service scheduleInRunLoop:[NSRunLoop currentRunLoop] 
						   forMode:NSRunLoopCommonModes];
		[service setDelegate:self];
		[service publish];
		
	}
	
}

-(void)initServiceBrowser {
	
	serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[serviceBrowser scheduleInRunLoop:[NSRunLoop currentRunLoop] 
							  forMode:NSRunLoopCommonModes];
	[serviceBrowser setDelegate:self];
	[serviceBrowser searchForServicesOfType:@"_mygame._tcp." inDomain:@""];
	
}

#pragma mark NSNetServiceBrowser delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
		   didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing {
	
	if(![[netService name] isEqualToString:ownName]) {
		[services addObject:netService];
		[servicesTable reloadData];
	}
	
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
		 didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
	
	[services removeObject:netService];
	[servicesTable reloadData];
	
}

#pragma mark NSNetService delegate methods

- (void)netServiceDidPublish:(NSNetService *)sender {
	
	// store own name for later
	ownName = [sender name];
	
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
	
	if (![netService getInputStream:&inStream outputStream:&outStream]) {
		// failed to connect
		return;
	}
	currentService = netService;
	[self openStreams];
	
	myTurn = YES;
	
}

#pragma mark NSStream methods

- (void)didAcceptConnectionWithinputStream:(NSInputStream *)istr
							  outputStream:(NSOutputStream *)ostr {
	
	// inStream and outStream are NSInputStream and NSOutputStream instance variables
	
	inStream = istr;
	[inStream retain];
	
	outStream = ostr;
	[outStream retain];
	
	[self openStreams];
	
}

-(void)openStreams {
	
	inStream.delegate = self;
	[inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
						forMode:NSDefaultRunLoopMode];
	[inStream open];
	
	outStream.delegate = self;
	[outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
						 forMode:NSDefaultRunLoopMode];
	[outStream open];
	
}

-(BOOL)send:(const uint8_t)message {
	
	if (outStream && [outStream hasSpaceAvailable])
		if([outStream write:(const uint8_t *)&message 
				  maxLength:sizeof(const uint8_t)] != -1) return YES;
	return NO;
	
}

- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
	
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
			// show game view
			[overlay setHidden:NO];
			
			// hide servicesTable view
			[servicesTable setHidden: YES];
			break;
			
		case NSStreamEventHasBytesAvailable:
		{ // braces to stop compiler complaining
			if (stream == inStream) {
				
				uint8_t b;
				unsigned int len = 0;
				len = [inStream read:&b maxLength:sizeof(uint8_t)];
				if(!len) {
					if ([stream streamStatus] != NSStreamStatusAtEnd) {
						// error reading data
					}
				} else {
					if(b<10) {
						// cell tapped by opponent
						[(Cell *)[overlay viewWithTag:b] remoteTap];
						myTurn = YES;
					} else if(b==10) {
						// use message '10' to indicate end of game
						[self endGame];
					} else if(b==11) {
						// use message '11' to reset game
						[self clearCells];
					}
				}
			}
			break;
		}
		case NSStreamEventEndEncountered:
			// opponent disconnected, end the game
			[self endGame];
			
			break;
	}
}

#pragma mark Game control methods

-(BOOL)tappedCell:(NSInteger)cellNumber {
	
	if(myTurn) {
		// send message to indicate choice of cell
		if([self send:(const uint8_t)cellNumber]) {
			myTurn = NO;
			return YES;
		}
	}
	return NO;
	
}

-(void)endGame {
	
	[self stopStreams];
	[self clearCells];
	// hide overlay
	[overlay setHidden: YES];
	myTurn = NO;
	
	// show servicesTable view
	[servicesTable setHidden: NO];
	
}

-(void)clearCells {
	
	// clear each cell
	NSInteger cell;
	for(cell=1;cell<=9;cell++) [(Cell *)[overlay viewWithTag:cell] clearCell];
	
}

#pragma mark Button press methods
-(void)endGameButton {
	
	[self endGame];
	// send message to end game
	[self send:(const uint8_t)10];
	
}

-(void)clearCellsButton {
	
	[self clearCells];
	// send message to clear cells
	[self send:(const uint8_t)11];
	
}

#pragma mark UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
	
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	
	NSString *title;
	switch (section) {
		case 0:
			title = @"Available Games";
			break;
	}
	
	return title;
	
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	return [services count];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *kCellIdentifier = @"TableRow";
	UITableViewCell *cell = [tableView 
							 dequeueReusableCellWithIdentifier:kCellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
									   reuseIdentifier:kCellIdentifier] autorelease];
	}
	
	// put service name as cell text
	cell.text = [[services objectAtIndex:indexPath.row] name];
	cell.accessoryView = nil;
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// user chose a service from table – start resolving it
	NSNetService *resolveService = [services objectAtIndex:indexPath.row];
	[resolveService setDelegate:self];
	[resolveService resolveWithTimeout:0.0];
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
	
}

#pragma mark cleaning up

-(void)stopService {
	
	[service stop];
	[service removeFromRunLoop:[NSRunLoop currentRunLoop] 
					   forMode:NSRunLoopCommonModes];
	[service release];
	service = nil;  
	
}

-(void)stopBrowsing {
	
	[serviceBrowser stop];
	[serviceBrowser release];
	serviceBrowser = nil;
	
}

-(void)stopStreams {
	
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
						forMode:NSDefaultRunLoopMode];
	[inStream release];
	inStream = nil;
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
						 forMode:NSDefaultRunLoopMode];
	[outStream release];
	outStream = nil;
	
	[currentService stop];
	currentService = nil;
	
}

-(void)closeSocket {
	
	if (socketRef) {
		CFSocketInvalidate(socketRef);
		CFRelease(socketRef);
		socketRef = NULL;
	}
	
}

- (void)dealloc {
	
	[super dealloc];
	[self stopService];
	[self stopBrowsing];
	[self stopStreams];
	[self closeSocket];
	[services release];
	[overlay release];
	
}

@end
