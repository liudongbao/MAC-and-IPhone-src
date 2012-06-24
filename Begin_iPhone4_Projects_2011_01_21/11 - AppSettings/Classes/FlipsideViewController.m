//
//  FlipsideViewController.m
//  AppSettings
//
//  Created by Dave Mark on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize engineSwitch;
@synthesize warpFactorSlider;

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    [self refreshFields];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self refreshFields];
	UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:app];
	
}

- (void)refreshFields {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    engineSwitch.on = ([[defaults objectForKey:kWarpDriveKey]
						isEqualToString:@"Engaged"]) ? YES : NO;
    warpFactorSlider.value = [defaults floatForKey:kWarpFactorKey];
}

- (IBAction)touchEngineSwitch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *prefValue = (engineSwitch.on) ? @"Engaged" : @"Disabled";
	[defaults setObject:prefValue forKey:kWarpDriveKey];
    [defaults synchronize];
}

- (IBAction)touchWarpSlider {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:warpFactorSlider.value forKey:kWarpFactorKey];
    [defaults synchronize];
}


- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.engineSwitch = nil;
    self.warpFactorSlider = nil;
    [super viewDidUnload];	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[engineSwitch release];
    [warpFactorSlider release];

    [super dealloc];
}


@end
