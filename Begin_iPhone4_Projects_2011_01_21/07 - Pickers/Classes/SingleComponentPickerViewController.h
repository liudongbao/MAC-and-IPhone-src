//
//  SingleComponentPickerViewController.h
//  Pickers
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleComponentPickerViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource> {
	UIPickerView    *singlePicker;
	NSArray         *pickerData;
}
@property (nonatomic, retain) IBOutlet UIPickerView *singlePicker;
@property (nonatomic, retain) NSArray *pickerData;
- (IBAction)buttonPressed;
@end
