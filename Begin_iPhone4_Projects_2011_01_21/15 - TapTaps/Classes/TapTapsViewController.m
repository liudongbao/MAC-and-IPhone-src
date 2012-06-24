//
//  TapTapsViewController.m
//  TapTaps
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TapTapsViewController.h"

@implementation TapTapsViewController
@synthesize singleLabel;
@synthesize doubleLabel;
@synthesize tripleLabel;
@synthesize quadrupleLabel;

- (void)tap1 {
    singleLabel.text = @"Single Tap Detected";
    [self performSelector:@selector(eraseMe:)
			   withObject:singleLabel afterDelay:1.6f];
}

- (void)tap2 {
    doubleLabel.text = @"Double Tap Detected";
    [self performSelector:@selector(eraseMe:)
			   withObject:doubleLabel afterDelay:1.6f];
}

- (void)tap3 {
    tripleLabel.text = @"Triple Tap Detected";
    [self performSelector:@selector(eraseMe:)
			   withObject:tripleLabel afterDelay:1.6f];
}

- (void)tap4 {
    quadrupleLabel.text = @"Quadruple Tap Detected";
    [self performSelector:@selector(eraseMe:)
			   withObject:quadrupleLabel afterDelay:1.6f];
}

- (void)eraseMe:(UITextField *)textField {
    textField.text = @"";
}



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UITapGestureRecognizer *singleTap =
	[[[UITapGestureRecognizer alloc] initWithTarget:self
											 action:@selector(tap1)] autorelease];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap =
	[[[UITapGestureRecognizer alloc] initWithTarget:self
											 action:@selector(tap2)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UITapGestureRecognizer *tripleTap =
	[[[UITapGestureRecognizer alloc] initWithTarget:self
											 action:@selector(tap3)] autorelease];
    tripleTap.numberOfTapsRequired = 3;
    tripleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tripleTap];
    [doubleTap requireGestureRecognizerToFail:tripleTap];
    
    UITapGestureRecognizer *quadrupleTap =
	[[[UITapGestureRecognizer alloc] initWithTarget:self
											 action:@selector(tap4)] autorelease];
    quadrupleTap.numberOfTapsRequired = 4;
    quadrupleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:quadrupleTap];
    [tripleTap requireGestureRecognizerToFail:quadrupleTap];	
}



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
	self.singleLabel = nil;
	self.doubleLabel = nil;
	self.tripleLabel = nil;
	self.quadrupleLabel = nil;
	[super viewDidUnload];
}

- (void)dealloc {
    [singleLabel release];
    [doubleLabel release];
    [tripleLabel release];
    [quadrupleLabel release];
    [super dealloc];
}

@end
