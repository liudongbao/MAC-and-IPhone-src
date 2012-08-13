//
//  ViewController.h
//  DateCalc
//
//  Created by John Ray on 10/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateChooserViewController.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *outputLabel;
@property (nonatomic) Boolean dateChooserVisible;

- (IBAction)showDateChooser:(id)sender;
- (void)calculateDateDifference:(NSDate *)chosenDate;

@end
