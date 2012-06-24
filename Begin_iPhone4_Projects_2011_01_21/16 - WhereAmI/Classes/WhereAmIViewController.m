//
//  WhereAmIViewController.m
//  WhereAmI
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhereAmIViewController.h"

@implementation WhereAmIViewController
@synthesize locationManager;
@synthesize startingPoint;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize horizontalAccuracyLabel;
@synthesize altitudeLabel;
@synthesize verticalAccuracyLabel;
@synthesize distanceTraveledLabel;

#pragma mark -
- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
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
	self.locationManager = nil;
	self.latitudeLabel = nil;
	self.longitudeLabel = nil;
	self.horizontalAccuracyLabel = nil;
	self.altitudeLabel = nil;
	self.verticalAccuracyLabel = nil;
	self.distanceTraveledLabel= nil;
	[super viewDidUnload];
}

- (void)dealloc {
    [locationManager release];
    [startingPoint release];
    [latitudeLabel release];
    [longitudeLabel release];
    [horizontalAccuracyLabel release];
    [altitudeLabel release];
    [verticalAccuracyLabel release];
    [distanceTraveledLabel release];
    [super dealloc];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	
	if (startingPoint == nil)
		self.startingPoint = newLocation;
	
	NSString *latitudeString = [[NSString alloc] initWithFormat:@"%g\u00B0",
								newLocation.coordinate.latitude];
	latitudeLabel.text = latitudeString;
	[latitudeString release];
	
	NSString *longitudeString = [[NSString alloc] initWithFormat:@"%g\u00B0",
								 newLocation.coordinate.longitude];
	longitudeLabel.text = longitudeString;
	[longitudeString release];
	
	NSString *horizontalAccuracyString = [[NSString alloc]
										  initWithFormat:@"%gm",
										  newLocation.horizontalAccuracy];
	horizontalAccuracyLabel.text = horizontalAccuracyString;
	[horizontalAccuracyString release];
	
	NSString *altitudeString = [[NSString alloc] initWithFormat:@"%gm",
								newLocation.altitude];
	altitudeLabel.text = altitudeString;
	[altitudeString release];
	
	NSString *verticalAccuracyString = [[NSString alloc]
										initWithFormat:@"%gm",
										newLocation.verticalAccuracy];
	verticalAccuracyLabel.text = verticalAccuracyString;
	[verticalAccuracyString release];
	
	CLLocationDistance distance = [newLocation
								   distanceFromLocation:startingPoint];
	NSString *distanceString = [[NSString alloc]
								initWithFormat:@"%gm", distance];
	distanceTraveledLabel.text = distanceString;
    [distanceString release];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	
    NSString *errorType = (error.code == kCLErrorDenied) ?
	@"Access Denied" : @"Unknown Error";
    UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Error getting Location"
						  message:errorType
						  delegate:nil
						  cancelButtonTitle:@"Okay"
						  otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
