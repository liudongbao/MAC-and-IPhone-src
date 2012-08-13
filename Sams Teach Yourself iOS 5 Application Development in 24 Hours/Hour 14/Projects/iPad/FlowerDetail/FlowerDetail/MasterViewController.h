//
//  MasterViewController.h
//  FlowerDetail
//
//  Created by John E. Ray on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSArray *flowerData;
@property (strong, nonatomic) NSArray *flowerSections;

- (void)createFlowerData;

@end
