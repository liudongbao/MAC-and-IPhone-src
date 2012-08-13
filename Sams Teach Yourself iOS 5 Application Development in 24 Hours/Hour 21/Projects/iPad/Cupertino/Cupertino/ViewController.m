//
//  ViewController.m
//  Cupertino
//
//  Created by John Ray on 9/19/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

#define kCupertinoLatitude  37.3229978
#define kCupertinoLongitude -122.0321823

@implementation ViewController

@synthesize locMan;
@synthesize distanceLabel;
@synthesize waitView;
@synthesize distanceView;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    
    if (newLocation.horizontalAccuracy >= 0) {
        CLLocation *Cupertino = [[CLLocation alloc]
                                 initWithLatitude:kCupertinoLatitude 
                                 longitude:kCupertinoLongitude];
        CLLocationDistance delta = [Cupertino 
                                    distanceFromLocation:newLocation];
        long miles = (delta * 0.000621371) + 0.5; // meters to rounded miles
        if (miles < 3) {
            // Stop updating the location
            [self.locMan stopUpdatingLocation];
            // Congratulate the user
            self.distanceLabel.text = @"Enjoy the\nMothership!";
        } else {
            NSNumberFormatter *commaDelimited = [[NSNumberFormatter alloc]
                                                 init];
            [commaDelimited setNumberStyle:NSNumberFormatterDecimalStyle];
            self.distanceLabel.text = [NSString stringWithFormat:
                                       @"%@ miles to the\nMothership",
                                       [commaDelimited stringFromNumber:
                                        [NSNumber numberWithLong:miles]]];
        }
        self.waitView.hidden = YES;
        self.distanceView.hidden = NO;
    }   
}


- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        // Turn off the location manager updates
        [self.locMan stopUpdatingLocation];
        [self setLocMan:nil];
    }
    self.waitView.hidden = YES;
    self.distanceView.hidden = NO; 
}

- (void)viewDidLoad
{
    locMan = [[CLLocationManager alloc] init];
    locMan.delegate = self;
    locMan.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locMan.distanceFilter = 1609; // a mile 
    [locMan startUpdatingLocation];

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLocMan:nil];
    [self setDistanceLabel:nil];
    [self setWaitView:nil];
    [self setDistanceView:nil];
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
