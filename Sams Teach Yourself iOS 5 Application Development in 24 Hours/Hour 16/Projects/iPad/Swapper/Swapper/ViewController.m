//
//  ViewController.m
//  Swapper
//
//  Created by John Ray on 9/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

#define kDeg2Rad (3.1415926/180.0)

@implementation ViewController
@synthesize portraitView;
@synthesize landscapeView;

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
    [self setPortraitView:nil];
    [self setLandscapeView:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)willRotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation 
                               duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation  
								   duration:duration];
	
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		self.view=self.landscapeView;
		self.view.transform=CGAffineTransformMakeRotation(kDeg2Rad*(90));
		self.view.bounds=CGRectMake(0.0,0.0,1024.0,768.0);
	} else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		self.view=self.landscapeView;
		self.view.transform=CGAffineTransformMakeRotation(kDeg2Rad*(-90));
		self.view.bounds=CGRectMake(0.0,0.0,1024.0,300.0);		
	} else {
		self.view=self.portraitView;
		self.view.transform=CGAffineTransformMakeRotation(0);
		self.view.bounds=CGRectMake(0.0,0.0,320.0,1004.0);
	}
}

@end
