//
//  ViewController.m
//  FlowerWeb
//
//  Created by John Ray on 9/2/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize colorChoice;
@synthesize flowerView;
@synthesize flowerDetailView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.flowerDetailView.hidden=YES;
	[self getFlower:nil];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setColorChoice:nil];
    [self setFlowerView:nil];
    [self setFlowerDetailView:nil];
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

- (IBAction)getFlower:(id)sender {
    NSURL *imageURL;
	NSURL *detailURL;
	NSString *imageURLString;
	NSString *detailURLString;
	NSString *color;
	int sessionID;
	
	color=[self.colorChoice titleForSegmentAtIndex:
		   self.colorChoice.selectedSegmentIndex];
	sessionID=random()%50000;
	
	imageURLString=[[NSString alloc] initWithFormat:
					@"http://www.floraphotographs.com/showrandomios.php?color=%@&session=%d"
					,color,sessionID];
	detailURLString=[[NSString alloc] initWithFormat:
					 @"http://www.floraphotographs.com/detailios.php?session=%d"
					 ,sessionID];
    
	imageURL=[[NSURL alloc] initWithString:imageURLString];
	detailURL=[[NSURL alloc] initWithString:detailURLString];
    
	[self.flowerView loadRequest:[NSURLRequest requestWithURL:imageURL]];
	[self.flowerDetailView loadRequest:[NSURLRequest requestWithURL:detailURL]];
	
	self.flowerDetailView.backgroundColor=[UIColor clearColor];
}

- (IBAction)toggleFlowerDetail:(id)sender {
    self.flowerDetailView.hidden=![sender isOn];
	/*
     if ([sender isOn]) {
     flowerDetailView.hidden=NO;
     } else {
     flowerDetailView.hidden=YES;
     }
     */
}

@end
