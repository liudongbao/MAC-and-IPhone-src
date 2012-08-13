//
//  ViewController.m
//  Survey
//
//  Created by John Ray on 9/10/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize resultsView;
@synthesize firstName;
@synthesize lastName;
@synthesize email;

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
    [self setResultsView:nil];
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setEmail:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)storeResults:(id)sender {
    
    NSString *csvLine=[NSString stringWithFormat:@"%@,%@,%@\n",
                       self.firstName.text,
                       self.lastName.text,
                       self.email.text];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                                    NSDocumentDirectory,
                                    NSUserDomainMask, YES) 
                        objectAtIndex: 0];
    NSString *surveyFile = [docDir 
                            stringByAppendingPathComponent:
                            @"surveyresults.csv"];
    
    if  (![[NSFileManager defaultManager] fileExistsAtPath:surveyFile]) {
        [[NSFileManager defaultManager] 
                createFileAtPath:surveyFile contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle 
                                fileHandleForUpdatingAtPath:surveyFile];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[csvLine 
                           dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    
    self.firstName.text=@"";
    self.lastName.text=@"";
    self.email.text=@"";
}

- (IBAction)showResults:(id)sender {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(
                                    NSDocumentDirectory,
                                    NSUserDomainMask, YES) 
                        objectAtIndex: 0];
    NSString *surveyFile = [docDir 
                            stringByAppendingPathComponent:
                            @"surveyresults.csv"];
    
    if  ([[NSFileManager defaultManager] fileExistsAtPath:surveyFile]) {
        NSFileHandle *fileHandle = [NSFileHandle 
                                    fileHandleForReadingAtPath:surveyFile];
        NSString *surveyResults=[[NSString alloc] 
                                 initWithData:[fileHandle availableData] 
                                 encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
        self.resultsView.text=surveyResults;
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [self.lastName resignFirstResponder];
    [self.firstName resignFirstResponder];
    [self.email resignFirstResponder];
}

@end