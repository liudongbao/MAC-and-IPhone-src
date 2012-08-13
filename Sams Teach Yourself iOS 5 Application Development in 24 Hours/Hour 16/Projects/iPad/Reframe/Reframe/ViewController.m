//
//  ViewController.m
//  Reframe
//
//  Created by John Ray on 9/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize buttonOne;
@synthesize buttonTwo;
@synthesize viewLabel;

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
    [self setButtonOne:nil];
    [self setButtonTwo:nil];
    [self setViewLabel:nil];
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

-(void)willRotateToInterfaceOrientation:
        (UIInterfaceOrientation)toInterfaceOrientation 
        duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation  
								   duration:duration];
	
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ||
		toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		self.viewLabel.frame=CGRectMake(400.0,340.0,225.0,60.0);
		self.buttonOne.frame=CGRectMake(20.0,20.0,983.0,185.0);
		self.buttonTwo.frame=CGRectMake(20.0,543.0,983.0,185.0);
	} else {
		self.viewLabel.frame=CGRectMake(275.0,20.0,225.0,60.0);
		self.buttonOne.frame=CGRectMake(20.0,168.0,728.0,400.0);
		self.buttonTwo.frame=CGRectMake(20.0,584.0,728.0,400.0);		
	}
}


@end
