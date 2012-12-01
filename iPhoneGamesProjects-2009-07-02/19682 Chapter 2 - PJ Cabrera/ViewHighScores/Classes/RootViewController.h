//
//  RootViewController.h
//  ViewHighScores
//
//  Created by PJ Cabrera on 1/13/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
	UITableView *myTableView;
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;

- (void)reloadData;

@end
