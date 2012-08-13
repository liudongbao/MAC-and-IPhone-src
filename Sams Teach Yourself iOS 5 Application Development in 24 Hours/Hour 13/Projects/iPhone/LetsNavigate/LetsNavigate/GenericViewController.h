//
//  GenericViewController.h
//  LetsNavigate
//
//  Created by John E. Ray on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountingNavigationController.h"

@interface GenericViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

- (IBAction)incrementCount:(id)sender;

@end
