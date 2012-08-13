//
//  AnimalChooserViewController.h
//  CustomPicker
//
//  Created by John Ray on 10/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AnimalChooserViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> 

@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) NSArray *animalNames;
@property (strong, nonatomic) NSArray *animalSounds;
@property (strong, nonatomic) NSArray *animalImages;

- (IBAction)dismissAnimalChooser:(id)sender;

@end
