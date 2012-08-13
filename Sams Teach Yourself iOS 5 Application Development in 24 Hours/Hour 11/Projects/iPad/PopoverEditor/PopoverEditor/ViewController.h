//
//  ViewController.h
//  PopoverEditor
//
//  Created by John Ray on 10/2/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditorViewController.h"

@interface ViewController : UIViewController <UIPopoverControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;

@end
