    //
//  YellowViewController.m
//  View Switcher
//
//  Created by Dave Mark on 12/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YellowViewController.h"


@implementation YellowViewController

- (IBAction)yellowButtonPressed
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Yellow View Button Pressed"
						  message:@"You pressed the button on the yellow view"
						  delegate:nil
						  cancelButtonTitle:@"Yep, I did."
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
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
}


- (void)dealloc {
    [super dealloc];
}


@end
