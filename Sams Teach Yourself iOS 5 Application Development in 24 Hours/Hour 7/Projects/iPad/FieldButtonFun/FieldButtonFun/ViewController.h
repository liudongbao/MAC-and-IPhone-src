//
//  ViewController.h
//  FieldButtonFun
//
//  Created by John Ray on 8/23/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *thePlace;
@property (strong, nonatomic) IBOutlet UITextField *theVerb;
@property (strong, nonatomic) IBOutlet UITextField *theNumber;
@property (strong, nonatomic) IBOutlet UITextView *theTemplate;
@property (strong, nonatomic) IBOutlet UITextView *theStory;
@property (strong, nonatomic) IBOutlet UIButton *theButton;

- (IBAction)createStory:(id)sender;
- (IBAction)hideKeyboard:(id)sender;



@end
