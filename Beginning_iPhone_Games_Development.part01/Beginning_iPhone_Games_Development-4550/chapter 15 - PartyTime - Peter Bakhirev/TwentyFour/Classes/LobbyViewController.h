//
//  LobbyViewController.h
//  TwentyFour
//

#import <UIKit/UIKit.h>


@interface LobbyViewController : UIViewController <UITableViewDataSource> {
  UITableView *gameList;
}

@property (nonatomic, retain) IBOutlet UITableView* gameList;

- (IBAction)startNewGame;
- (IBAction)joinSelectedGame;

@end
