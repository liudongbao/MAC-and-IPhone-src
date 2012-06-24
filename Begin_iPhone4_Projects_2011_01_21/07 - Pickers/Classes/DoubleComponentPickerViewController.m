//
//  DoubleComponentPickerViewController.m
//  Pickers
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DoubleComponentPickerViewController.h"


@implementation DoubleComponentPickerViewController
@synthesize doublePicker;
@synthesize fillingTypes;
@synthesize breadTypes;

-(IBAction)buttonPressed
{
    NSInteger fillingRow = [doublePicker selectedRowInComponent:
							kFillingComponent];
    NSInteger breadRow = [doublePicker selectedRowInComponent:
                          kBreadComponent];
	
	
    NSString *bread = [breadTypes objectAtIndex:breadRow];
    NSString *filling = [fillingTypes objectAtIndex:fillingRow];
	
    NSString *message = [[NSString alloc] initWithFormat:
						 @"Your %@ on %@ bread will be right up.", filling, bread];
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
						  @"Thank you for your order"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Great!"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [message release];
}

- (void)viewDidLoad {
    NSArray *fillingArray = [[NSArray alloc] initWithObjects:@"Ham",
							 @"Turkey", @"Peanut Butter", @"Tuna Salad",
							 @"Nutella", @"Roast Beef", @"Vegemite", nil];
    self.fillingTypes = fillingArray;
    [fillingArray release];
	
    NSArray *breadArray = [[NSArray alloc] initWithObjects:@"White",
						   @"Whole Wheat", @"Rye", @"Sourdough", @"Seven Grain",nil];
    self.breadTypes = breadArray;
    [breadArray release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.doublePicker = nil;
    self.breadTypes = nil;
    self.fillingTypes = nil;	
}


- (void)dealloc {
	[doublePicker release];
    [breadTypes release];
    [fillingTypes release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if (component == kBreadComponent)
        return [self.breadTypes count];
	
    return [self.fillingTypes count];
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component {
    if (component == kBreadComponent)
        return [self.breadTypes objectAtIndex:row];
    return [self.fillingTypes objectAtIndex:row];
}

@end
