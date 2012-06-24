//
//  GLFunViewController.h
//  GLFun
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLFunViewController : UIViewController {
    UISegmentedControl *colorControl;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *colorControl;
- (IBAction)changeColor:(id)sender;
- (IBAction)changeShape:(id)sender;
@end

