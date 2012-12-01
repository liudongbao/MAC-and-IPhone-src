//
//  LobbyViewController.m
//  TwentyFour
//

#import "LobbyViewController.h"
#import "TwentyFourAppDelegate.h"


@implementation LobbyViewController

@synthesize gameList, netServiceBrowser, selectedGame;

- (void)viewDidLoad {
  netServiceBrowser = [[NSNetServiceBrowser alloc] init];
  netServiceBrowser.delegate = self;
  games = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
  [games removeAllObjects];
  [gameList reloadData];
  [netServiceBrowser searchForServicesOfType:@"_twentyfour._tcp." inDomain:@""];
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [netServiceBrowser stop];
  [super viewDidDisappear:animated];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
    didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
  // Make sure that we don't have such game already
  if ( ! [games containsObject:netService] ) {
    // Add it to our list
    [games addObject:netService];
  }

  // If more entries are coming, no need to update UI just yet
  if ( !moreServicesComing ) {
    [gameList reloadData];
  }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
    didRemoveService:(NSNetService *)netService
    moreComing:(BOOL)moreServicesComing {
  // Remove from list
  [games removeObject:netService];

  // If more entries are coming, no need to update UI just yet
  if ( !moreServicesComing ) {
    [gameList reloadData];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
    (NSInteger)section {
  return [games count];
}

// Table view is requesting a cell
- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString* gameListIdentifier = @"gameListIdentifier";

  UITableViewCell *cell = (UITableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:gameListIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
        reuseIdentifier:gameListIdentifier] autorelease];
	}

  // Set cell's text to game's name
  NSNetService* server = [games objectAtIndex:indexPath.row];
  cell.textLabel.text = [server name];
  
  return cell;
}

- (IBAction)startNewGame {
  [[TwentyFourAppDelegate getInstance] startNewGame];
}

- (IBAction)joinSelectedGame {
  // Is anything selected?
  NSIndexPath *currentRow = [gameList indexPathForSelectedRow];
  if ( currentRow == nil ) {
    return;
  }

  // Waiting for results to go through
  [[TwentyFourAppDelegate getInstance] showWaitingScreen];

  // Resolve this service
  self.selectedGame = [games objectAtIndex:currentRow.row];
  selectedGame.delegate = self;
  [selectedGame resolveWithTimeout:5.0];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
  if ( sender != selectedGame ) {
    return;
  }

  [[TwentyFourAppDelegate getInstance] hideWaitingScreen];

  [selectedGame stop];
  selectedGame.delegate = nil;
  self.selectedGame = nil;

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
      message:@"Selected game is not available" delegate:nil
      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
  if ( sender != selectedGame ) {
    return;
  }

  [[TwentyFourAppDelegate getInstance] hideWaitingScreen];

  NSInputStream *inputStream;
  NSOutputStream *outputStream;
  if ( ! [selectedGame getInputStream:&inputStream outputStream:&outputStream]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
        message:@"Could not connect to selected game" delegate:nil
        cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [selectedGame stop];
    selectedGame.delegate = nil;
    self.selectedGame = nil;
    return;
  }

  [selectedGame stop];
  selectedGame.delegate = nil;
  self.selectedGame = nil;

  Connection *connection = [[[Connection alloc] initWithInputStream:inputStream
      outputStream:outputStream] autorelease];

  [[TwentyFourAppDelegate getInstance] connectToGame:connection];
}

- (void)dealloc {
  self.gameList = nil;
  self.netServiceBrowser = nil;
  self.selectedGame = nil;
  [games release];
  games = nil;
  [super dealloc];
}

@end
