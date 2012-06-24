//
//  TapTapsViewController.h
//  TapTaps
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapTapsViewController : UIViewController {
    UILabel *singleLabel;
    UILabel *doubleLabel;
    UILabel *tripleLabel;
    UILabel *quadrupleLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *singleLabel;
@property (nonatomic, retain) IBOutlet UILabel *doubleLabel;
@property (nonatomic, retain) IBOutlet UILabel *tripleLabel;
@property (nonatomic, retain) IBOutlet UILabel *quadrupleLabel;
- (void)tap1;
- (void)tap2;
- (void)tap3;
- (void)tap4;
- (void)eraseMe:(UITextField *)textField ;
@end