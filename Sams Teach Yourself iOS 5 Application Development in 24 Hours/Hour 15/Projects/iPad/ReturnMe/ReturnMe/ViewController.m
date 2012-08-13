//
//  ViewController.m
//  ReturnMe
//
//  Created by John Ray on 9/15/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"
#define kName @"name"
#define kEmail @"email"
#define kPhone @"phone"
#define kPicture @"picture"

@implementation ViewController
@synthesize picture;
@synthesize name;
@synthesize email;
@synthesize phone;


-(void)setValuesFromPreferences {    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *initialDefaults=[[NSDictionary alloc] 
                                   initWithObjectsAndKeys:
                                   @"Dog", kPicture, 
                                   @"Your Name", kName, 
                                   @"you@yours.com",kEmail,
                                   @"(555)555-1212",kPhone,
                                   nil];
    [userDefaults registerDefaults:initialDefaults];
   // [userDefaults synchronize];
    
    NSString *picturePreference = [userDefaults stringForKey:kPicture];
    if ([picturePreference isEqualToString:@"Dog"]) {
        self.picture.image = [UIImage imageNamed:@"dog1.png"];
    } else if ([picturePreference isEqualToString:@"Crazy Dog"]) {
        self.picture.image = [UIImage imageNamed:@"dog2.png"];
    } else {
        self.picture.image = [UIImage imageNamed:@"coral.png"];
    }
    
    self.name.text = [userDefaults stringForKey:kName];
    self.email.text = [userDefaults stringForKey:kEmail];
    self.phone.text = [userDefaults stringForKey:kPhone];
}   

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setValuesFromPreferences];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setPicture:nil];
    [self setName:nil];
    [self setEmail:nil];
    [self setPhone:nil];
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
