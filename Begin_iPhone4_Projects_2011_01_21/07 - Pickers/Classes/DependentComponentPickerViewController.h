//
//  DependentComponentPickerViewController.h
//  Pickers
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kStateComponent   0
#define kZipComponent     1

@interface DependentComponentPickerViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource> {
    UIPickerView    *picker;
	
    NSDictionary    *stateZips;
    NSArray         *states;
    NSArray         *zips;
}
@property (retain, nonatomic) IBOutlet UIPickerView *picker;
@property (retain, nonatomic) NSDictionary *stateZips;
@property (retain, nonatomic) NSArray *states;
@property (retain, nonatomic) NSArray *zips;
- (IBAction) buttonPressed;
@end

