//
//  ViewController.h
//  GettingAttention
//
//  Created by John Ray on 9/9/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UILabel *userOutput;

- (IBAction)doAlert:(id)sender;
- (IBAction)doMultiButtonAlert:(id)sender;
- (IBAction)doAlertInput:(id)sender;
- (IBAction)doActionSheet:(id)sender;
- (IBAction)doSound:(id)sender;
- (IBAction)doAlertSound:(id)sender;
- (IBAction)doVibration:(id)sender;
@end
