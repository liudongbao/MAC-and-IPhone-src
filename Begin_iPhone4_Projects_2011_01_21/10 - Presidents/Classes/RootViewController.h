//
//  RootViewController.h
//  Presidents
//
//  Created by Dave Mark on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {	
    DetailViewController *detailViewController;
    NSArray *presidents;
}
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSArray *presidents;
@end
