//
//  ViewController.m
//  DateCalc
//
//  Created by John Ray on 10/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize outputLabel;
@synthesize dateChooserVisible;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setOutputLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((DateChooserViewController *)segue.destinationViewController).delegate=self;
}

- (IBAction)showDateChooser:(id)sender {
    if (self.dateChooserVisible!=YES) {
        [self performSegueWithIdentifier:@"toDateChooser" sender:sender];
        self.dateChooserVisible=YES;
    }
}

- (void)calculateDateDifference:(NSDate *)chosenDate {
    NSDate *todaysDate;
	NSString *differenceOutput;
	NSString *todaysDateString;
    NSString *chosenDateString;
	NSDateFormatter *dateFormat;
	NSTimeInterval difference;
    
	todaysDate=[NSDate date];
	difference = [todaysDate timeIntervalSinceDate:chosenDate] / 86400; 
	
	dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM d, yyyy hh:mm:ssa"];
	todaysDateString = [dateFormat stringFromDate:todaysDate];
    chosenDateString = [dateFormat stringFromDate:chosenDate];
    
	differenceOutput=[[NSString alloc] initWithFormat:
					  @"Difference between chosen date (%@) and today (%@) in days: %1.2f",
					  chosenDateString,todaysDateString,fabs(difference)];
	self.outputLabel.text=differenceOutput;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
