//
//  ResultsViewController.h
//  TwentyFour
//
//  Created by Peter Bakhyryev on 8/10/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResultsViewController : UIViewController <UITableViewDataSource> {
  NSArray *results;
  UILabel *labelStatus;
  UITableView *tableResults;
}

@property (nonatomic, retain) IBOutlet UILabel *labelStatus;
@property (nonatomic, retain) IBOutlet UITableView *tableResults;
@property (nonatomic, retain) NSArray *results;

@end
