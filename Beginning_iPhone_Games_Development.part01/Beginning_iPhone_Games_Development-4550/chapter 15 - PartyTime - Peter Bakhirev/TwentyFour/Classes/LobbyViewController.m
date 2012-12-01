//
//  LobbyViewController.m
//  TwentyFour
//

#import "LobbyViewController.h"
#import "TwentyFourAppDelegate.h"


@implementation LobbyViewController

@synthesize gameList;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
    (NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return nil;
}

- (IBAction)startNewGame {
  [[TwentyFourAppDelegate getInstance] startNewGame];
}

- (IBAction)joinSelectedGame {
}

- (void)dealloc {
  self.gameList = nil;
  [super dealloc];
}

@end
