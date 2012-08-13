//
//  DateChooserViewController.h
//  DateCalc
//
//  Created by John Ray on 10/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface DateChooserViewController : UIViewController

@property (strong, nonatomic) id delegate;

- (IBAction)dismissDateChooser:(id)sender;
- (IBAction)setDateTime:(id)sender;

@end
