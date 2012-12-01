//
//  CoreAChickenViewController.m
//  CoreAChicken
//
//  Created by PJ Cabrera on 9/3/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "CoreAChickenViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CoreAChickenViewController

@synthesize animateButton;
@synthesize firstView;
@synthesize secondView;
@synthesize theChicken;
@synthesize theRoad;

- (void)dealloc {
	[animateButton release];
	[firstView release];
	[secondView release];
	[theChicken release];
	[theRoad release];
    [super dealloc];
}

- (IBAction)animate {
	static int counter = 0;
	switch (++counter) {
		default:
			counter = 0;
			break;
	}
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
