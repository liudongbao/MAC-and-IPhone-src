//
//  ViewController.m
//  Disconnected
//
//  Created by John Ray on 8/14/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize colorChoice;
@synthesize chosenColor;
@synthesize flowerView;


-(IBAction)getFlower:(id)sender {
	NSString *outputHTML;
	NSString *color;
	NSString *colorVal;
	int colorNum;
	colorNum=colorChoice.selectedSegmentIndex;
	switch (colorNum) {
		case 0:
			color=@"Red";
			colorVal=@"red";
			break;
		case 1:
			color=@"Blue";
			colorVal=@"blue";
			break;
		case 2:
			color=@"Yellow";
			colorVal=@"yellow";
			break;
		case 3:
			color=@"Green";
			colorVal=@"green";
			break;
	}
	chosenColor.text=[[NSString alloc] initWithFormat:@"%@",color];
	outputHTML=[[NSString alloc] initWithFormat:@"<body style='margin: 0px; padding: 0px'><img height='1200' src='http://www.floraphotographs.com/showrandom.php?color=%@'></body>",colorVal];
	[flowerView loadHTMLString:outputHTML baseURL:nil];
}

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
    [self setFlowerView:nil];
    [self setChosenColor:nil];
    [self setColorChoice:nil];
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
