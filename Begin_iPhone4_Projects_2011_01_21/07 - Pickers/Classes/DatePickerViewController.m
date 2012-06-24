//
//  DatePickerViewController.m
//  Pickers
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController
@synthesize datePicker;

- (IBAction)buttonPressed {
    NSDate *selected = [datePicker date];
    NSString *message = [[NSString alloc] initWithFormat:
						 @"The date and time you selected is: %@", selected];
    UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Date and Time Selected"
						  message:message
						  delegate:nil
						  cancelButtonTitle:@"Yes, I did."
						  otherButtonTitles:nil];
    [alert show];
    [alert release];
    [message release];
}

- (void)viewDidLoad {
    NSDate *now = [[NSDate alloc] init];
    [datePicker setDate:now animated:NO];
    [now release];
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
	self.datePicker = nil;
}


- (void)dealloc {
	[datePicker release];
	[super dealloc];
}


@end
