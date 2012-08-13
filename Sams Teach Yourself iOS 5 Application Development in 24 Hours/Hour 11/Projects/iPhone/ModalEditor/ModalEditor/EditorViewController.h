//
//  EditorViewController.h
//  ModalEditor
//
//  Created by John Ray on 10/2/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface EditorViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *emailField;

- (IBAction)dismissEditor:(id)sender;
@end
