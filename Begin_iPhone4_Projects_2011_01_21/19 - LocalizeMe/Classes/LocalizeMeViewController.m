//
//  LocalizeMeViewController.m
//  LocalizeMe
//
//  Created by JN on 10/29/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LocalizeMeViewController.h"

@implementation LocalizeMeViewController

@synthesize localeLabel;
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize label5;

- (void)viewDidLoad {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *displayNameString = [locale
                                   displayNameForKey:NSLocaleIdentifier
                                   value:[locale localeIdentifier]];
    localeLabel.text = displayNameString;
    
    label1.text = NSLocalizedString(@"One", @"The number 1");
    label2.text = NSLocalizedString(@"Two", @"The number 2");
    label3.text = NSLocalizedString(@"Three", @"The number 3");
    label4.text = NSLocalizedString(@"Four", @"The number 4");
    label5.text = NSLocalizedString(@"Five", @"The number 5");
    [super viewDidLoad];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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
    self.localeLabel = nil;
    self.label1 = nil;
    self.label2 = nil;
    self.label3 = nil;
    self.label4 = nil;
    self.label5 = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [localeLabel release];
    [label1 release];
    [label2 release];
    [label3 release];
    [label4 release];
    [label5 release];
    [super dealloc];
}
@end
