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
#define kDeg2Rad 0.0174532925
#define kRad2Deg 57.2957795
#define kStraight 1
#define kRight 2
#define kLeft 3

@implementation ViewController

@synthesize locMan;
@synthesize distanceLabel;
@synthesize waitView;
@synthesize distanceView;
@synthesize directionArrow;
@synthesize recentLocation;


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
        
        // Store the location for use during heading updates
        self.recentLocation = newLocation;
        
        CLLocation *Cupertino = [[CLLocation alloc]
                                 initWithLatitude:kCupertinoLatitude 
                                 longitude:kCupertinoLongitude];
        CLLocationDistance delta = [Cupertino 
                                    distanceFromLocation:newLocation];
        long miles = (delta * 0.000621371) + 0.5; // meters to rounded miles
        if (miles < 3) {
            // Stop updating the location and heading
            [self.locMan stopUpdatingLocation];
            [self.locMan stopUpdatingHeading];
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

/*
 * According to Movable Type Scripts
 * http://mathforum.org/library/drmath/view/55417.html
 *
 *  Javascript:
 *	
 * var y = Math.sin(dLon) * Math.cos(lat2);
 * var x = Math.cos(lat1)*Math.sin(lat2) -
 * Math.sin(lat1)*Math.cos(lat2)*Math.cos(dLon);
 * var brng = Math.atan2(y, x).toDeg();
 */
-(double)headingToLocation:(CLLocationCoordinate2D)desired
                   current:(CLLocationCoordinate2D)current {
    
    // Gather the variables needed by the heading algorithm
    double lat1 = current.latitude*kDeg2Rad;
    double lat2 = desired.latitude*kDeg2Rad;
    double lon1 = current.longitude;
    double lon2 = desired.longitude;
    double dlon = (lon2-lon1)*kDeg2Rad;
    
    double y = sin(dlon)*cos(lat2);
    double x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(dlon);
    
    double heading=atan2(y,x);
    heading=heading*kRad2Deg;
    heading=heading+360.0;
    heading=fmod(heading,360.0);
    return heading;
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {
    
    if (self.recentLocation != nil && newHeading.headingAccuracy >= 0) {
        CLLocation *cupertino = [[CLLocation alloc]
                                 initWithLatitude:kCupertinoLatitude
                                 longitude:kCupertinoLongitude];
        double course = [self headingToLocation:cupertino.coordinate
                                        current:recentLocation.coordinate];
        double delta = newHeading.trueHeading - course;
        if (abs(delta) <= 10) {
            self.directionArrow.image = [UIImage imageNamed:
                                         @"up_arrow.png"];
            if (lastSound!=kStraight) {
                AudioServicesPlaySystemSound(soundStraight);
                lastSound=kStraight;
            }
        } 
        else 
        {
            if (delta > 180) { 
                self.directionArrow.image = [UIImage imageNamed:
                                        @"right_arrow.png"];
                if (lastSound!=kRight) {
                    AudioServicesPlaySystemSound(soundRight);
                    lastSound=kRight;
                }
            }
            else if (delta > 0) {
                self.directionArrow.image = [UIImage imageNamed:
                                        @"left_arrow.png"];
                if (lastSound!=kLeft) {
                    AudioServicesPlaySystemSound(soundLeft);
                    lastSound=kLeft;
                }
            }
            else if (delta > -180) {
                self.directionArrow.image = [UIImage imageNamed:
                                        @"right_arrow.png"];
                if (lastSound!=kRight) {
                    AudioServicesPlaySystemSound(soundRight);
                    lastSound=kRight;
                }
            }
            else {
                self.directionArrow.image = [UIImage imageNamed:
                                         @"left_arrow.png"];
                if (lastSound!=kLeft) {
                    AudioServicesPlaySystemSound(soundLeft);
                    lastSound=kLeft;
                }
            }
        }
        self.directionArrow.hidden = NO;
    } else {
        self.directionArrow.hidden = YES;
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
    
    NSString *soundFile;
    
    soundFile = [[NSBundle mainBundle] pathForResource:@"straight" 
                                                ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)
                                     [NSURL fileURLWithPath:soundFile]
                                     ,&soundStraight);
    
    soundFile = [[NSBundle mainBundle] pathForResource:@"right" 
                                                ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)
                                     [NSURL fileURLWithPath:soundFile]
                                     ,&soundRight);
    
    soundFile = [[NSBundle mainBundle] pathForResource:@"left" 
                                                ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)
                                     [NSURL fileURLWithPath:soundFile]
                                     ,&soundLeft);

    lastSound=0;
    
    // Nothing changes below this line.
    locMan = [[CLLocationManager alloc] init];
    locMan.delegate = self;
    locMan.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locMan.distanceFilter = 1609; // a mile 
    [locMan startUpdatingLocation];
    
    if ([CLLocationManager headingAvailable]) {
        locMan.headingFilter = 10; // 10 degrees
        [locMan startUpdatingHeading];
    } 
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setLocMan:nil];
    [self setDistanceLabel:nil];
    [self setRecentLocation:nil];
    [self setWaitView:nil];
    [self setDistanceView:nil];
    [self setDirectionArrow:nil];
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
