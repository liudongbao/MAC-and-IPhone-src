//
//  TicTacToeViewController.h
//  TicTacToe
//
//  Created by Swipe Interactive on 3/10/09.
//  Copyright Swipe Interactive 2009. All rights reserved.
//

#import <netinet/in.h>
#import <sys/socket.h>
#import <CFNetwork/CFSocketStream.h>
#import <UIKit/UIKit.h>

@interface TicTacToeViewController : UIViewController {
	
	UIView *overlay;
	
	BOOL myTurn;
	
	CFSocketRef socketRef;
	NSNetService *service;
	NSNetService *currentService;
	NSNetServiceBrowser *serviceBrowser;
	NSInputStream *inStream;
	NSOutputStream *outStream;
	NSString *ownName;
	NSMutableArray *services;
	
	IBOutlet UITableView *servicesTable;
}

-(CFSocketRef)initSocket;
-(void)publishService;
-(void)initServiceBrowser;
-(void)openStreams;
-(void)didAcceptConnectionWithinputStream:(NSInputStream *)istr
							 outputStream:(NSOutputStream *)ostr;
-(BOOL)send:(const uint8_t)message;
-(BOOL)tappedCell:(NSInteger)cellNumber;
-(void)endGame;
-(void)clearCells;
-(void)endGameButton;
-(void)clearCellsButton;
-(void)stopService;
-(void)stopBrowsing;
-(void)stopStreams;
-(void)closeSocket;

@property (nonatomic, retain) IBOutlet UITableView *servicesTable;

@end
