//
//  GenericViewController.m
//  LetsTab
//
//  Created by John E. Ray on 10/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericViewController.h"

@implementation GenericViewController
@synthesize outputLabel;
@synthesize barItem;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

-(void)updateCounts {
    NSString *countString;
    countString=[[NSString alloc] initWithFormat:
                 @"First: %d\nSecond: %d\nThird: %d",
                 ((CountingTabBarController *)self.parentViewController).firstCount,
                 ((CountingTabBarController *)self.parentViewController).secondCount,
                 ((CountingTabBarController *)self.parentViewController).thirdCount];
    self.outputLabel.text=countString;
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateCounts];
}

-(void)updateBadge {
    NSString *badgeCount;
    int     currentBadge;
    currentBadge=[self.barItem.badgeValue intValue];
    currentBadge++;
    badgeCount=[[NSString alloc] initWithFormat:@"%d",
                currentBadge];
    self.barItem.badgeValue=badgeCount;
}


- (void)viewDidUnload
{
    [self setOutputLabel:nil];
    [self setBarItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)incrementCountFirst:(id)sender {
    ((CountingTabBarController *)self.parentViewController).firstCount++;
    [self updateBadge];
    [self updateCounts];
}

- (IBAction)incrementCountSecond:(id)sender {
    ((CountingTabBarController *)self.parentViewController).secondCount++;
    [self updateBadge];
    [self updateCounts];
}

- (IBAction)incrementCountThird:(id)sender {
    ((CountingTabBarController *)self.parentViewController).thirdCount++;
    [self updateBadge];
    [self updateCounts];
}

@end
