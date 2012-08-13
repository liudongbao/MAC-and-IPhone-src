//
//  ViewController.m
//  HelloSimulator
//
//  Created by John Ray on 8/7/11.
//  Copyright 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize webView;

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {	
	UIAlertView *alertDialog;
	
	alertDialog = [[UIAlertView alloc] 
				   initWithTitle: @"Stop shaking me!!!" 
				   message:@"I'm about to get seasick!" 
				   delegate: nil 
				   cancelButtonTitle: @"Ok"
				   otherButtonTitles: nil];
	[alertDialog show];
}

- (BOOL)canBecomeFirstResponder { 
	return YES; 
}

- (void)didReceiveMemoryWarning
{
    UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc] 
				   initWithTitle: @"Where did my memory go ?" 
				   message:@"I'm losing my mind!" 
				   delegate: nil 
				   cancelButtonTitle: @"Ok"
				   otherButtonTitles: nil];
	[alertDialog show];
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self.webView loadHTMLString:@"<html><body style='width:100%;text-align: center; font-family: Helvetica; font-size:72px; margin-right:0px; margin-left:0px; margin-top:25px;'>Hello<br/> iOS Simulator<br/><br/><img style='width:100%' src='http://www.floraphotographs.com/showrandom.php'></body></html>" baseURL:nil];
	[self.view becomeFirstResponder];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
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

@end
