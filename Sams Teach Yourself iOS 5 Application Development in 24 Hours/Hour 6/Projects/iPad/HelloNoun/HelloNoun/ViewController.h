//
//  ViewController.h
//  HelloNoun
//
//  Created by John Ray on 8/18/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UILabel *userOutput;
@property (strong, nonatomic) IBOutlet UITextField *userInput;

- (IBAction)setOutput:(id)sender;

@end
