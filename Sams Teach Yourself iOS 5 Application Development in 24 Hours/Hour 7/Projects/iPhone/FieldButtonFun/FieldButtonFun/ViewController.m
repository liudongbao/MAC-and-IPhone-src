//
//  ViewController.m
//  FieldButtonFun
//
//  Created by John Ray on 8/23/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize thePlace;
@synthesize theVerb;
@synthesize theNumber;
@synthesize theTemplate;
@synthesize theStory;
@synthesize theButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIImage *normalImage = [[UIImage imageNamed:@"whiteButton.png"] 
                            stretchableImageWithLeftCapWidth:12.0 
							topCapHeight:0.0];
	UIImage *pressedImage = [[UIImage imageNamed:@"blueButton.png"]
                            stretchableImageWithLeftCapWidth:12.0 
							topCapHeight:0.0];
    [self.theButton setBackgroundImage:normalImage 
                              forState:UIControlStateNormal];
	[self.theButton setBackgroundImage:pressedImage 
                            forState:UIControlStateHighlighted];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setThePlace:nil];
    [self setTheVerb:nil];
    [self setTheNumber:nil];
    [self setTheTemplate:nil];
    [self setTheStory:nil];
    [self setTheButton:nil];
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

/*  1:*/- (IBAction)createStory:(id)sender {
/*  2:*/    self.theStory.text=[self.theTemplate.text
/*  3:*/                        stringByReplacingOccurrencesOfString:@"<place>"
/*  4:*/                        withString:self.thePlace.text];
/*  5:*/    self.theStory.text=[self.theStory.text
/*  6:*/                        stringByReplacingOccurrencesOfString:@"<verb>"
/*  7:*/                        withString:self.theVerb.text];
/*  8:*/    self.theStory.text=[self.theStory.text
/*  9:*/                        stringByReplacingOccurrencesOfString:@"<number>"
/* 10:*/                        withString:self.theNumber.text];
/* 11:*/}


- (IBAction)hideKeyboard:(id)sender {
    [self.thePlace resignFirstResponder];
    [self.theVerb resignFirstResponder];
    [self.theNumber resignFirstResponder];
    [self.theTemplate resignFirstResponder];
}


@end
