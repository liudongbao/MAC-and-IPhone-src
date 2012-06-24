//
//  CustomPickerViewController.h
//  Pickers
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CustomPickerViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate> {
    UIPickerView *picker;
    UILabel *winLabel;
	
    NSArray *column1;
    NSArray *column2;
    NSArray *column3;
    NSArray *column4;
    NSArray *column5;
	
	UIButton *button;
	
	SystemSoundID	crunchSoundID;
	SystemSoundID	winSoundID;
}
@property(nonatomic, retain) IBOutlet UIPickerView *picker;
@property(nonatomic, retain) IBOutlet UILabel *winLabel;
@property(nonatomic, retain) NSArray *column1;
@property(nonatomic, retain) NSArray *column2;
@property(nonatomic, retain) NSArray *column3;
@property(nonatomic, retain) NSArray *column4;
@property(nonatomic, retain) NSArray *column5;
@property(nonatomic, retain) IBOutlet UIButton *button;
@property(nonatomic) SystemSoundID crunchSoundID;
@property(nonatomic) SystemSoundID winSoundID;
- (IBAction)spin;
@end
