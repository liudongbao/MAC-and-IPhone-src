//
//  LobbyViewController.h
//  TwentyFour
//

#import <UIKit/UIKit.h>


@interface LobbyViewController : UIViewController <UITableViewDataSource> {
  UITableView *gameList;
  NSMutableArray *games;
  NSNetServiceBrowser *netServiceBrowser;
  NSNetService *selectedGame;
}

@property (nonatomic, retain) IBOutlet UITableView* gameList;
@property (nonatomic, retain) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, retain) NSNetService *selectedGame;

- (IBAction)startNewGame;
- (IBAction)joinSelectedGame;

@end
