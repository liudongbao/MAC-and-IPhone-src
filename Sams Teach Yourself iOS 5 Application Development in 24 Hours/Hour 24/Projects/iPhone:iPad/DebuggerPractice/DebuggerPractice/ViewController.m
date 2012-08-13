//
//  ViewController.m
//  DebuggerPractice
//
//  Created by John Ray on 9/16/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(NSString *)describeInteger:(int)i {
    if (i % 2 == 0) {
        return @"even";
    } else {
        return @"odd";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *description;
    
    NSLog(@"Start");
    for (int i = 1;i <= 2000;i++) {
        description = [self describeInteger:i];
        NSLog(@"Variables: i - %d and description - %@", i, description);
        NSLog(@"----");
    }
    NSLog(@"Done");
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
