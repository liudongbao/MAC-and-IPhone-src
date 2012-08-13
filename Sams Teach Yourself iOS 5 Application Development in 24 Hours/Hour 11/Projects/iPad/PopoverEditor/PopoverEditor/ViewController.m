//
//  ViewController.m
//  PopoverEditor
//
//  Created by John Ray on 10/2/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize emailLabel;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIStoryboardPopoverSegue *popoverSegue;
    popoverSegue=(UIStoryboardPopoverSegue *)segue;
    
    UIPopoverController *popoverController;
    popoverController=popoverSegue.popoverController;
    popoverController.delegate=self;
    
    EditorViewController *editorVC;
    editorVC=(EditorViewController *)popoverController.contentViewController;
    editorVC.emailField.text=self.emailLabel.text;
}


- (void)popoverControllerDidDismissPopover:
                        (UIPopoverController *)popoverController {
    NSString *newEmail;
    newEmail=((EditorViewController *)
              popoverController.contentViewController).emailField.text;
    self.emailLabel.text=newEmail;
}


- (void)viewDidUnload
{
    [self setEmailLabel:nil];
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
    return YES;
}

@end
