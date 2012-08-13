//
//  ViewController.m
//  ColorTilt
//
//  Created by John Ray on 9/4/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize colorView;
@synthesize toggleAccelerometer;
@synthesize toggleGyroscope;
@synthesize motionManager;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .01;
    self.motionManager.gyroUpdateInterval = .01;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setColorView:nil];
    [self setToggleAccelerometer:nil];
    [self setToggleGyroscope:nil];
    [self setMotionManager:nil];
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
    return NO;
}

- (IBAction)controlHardware:(id)sender {
    if ([self.toggleAccelerometer isOn]) {
        [self.motionManager 
          startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
          withHandler:^(CMAccelerometerData *accelData, NSError *error) {
             [self doAcceleration:accelData.acceleration];
         }];
	} else {
        [self.motionManager stopAccelerometerUpdates];
    }
    
    if ([self.toggleGyroscope isOn] && self.motionManager.gyroAvailable) {
        [self.motionManager 
          startGyroUpdatesToQueue:[NSOperationQueue currentQueue] 
          withHandler:^(CMGyroData *gyroData, NSError *error) {
             [self doRotation:gyroData.rotationRate];
         }];
    } else {
		[self.toggleGyroscope setOn:NO animated:YES];
        [self.motionManager stopGyroUpdates];
    }
}

- (void)doAcceleration:(CMAcceleration)acceleration {
    if (acceleration.x > 1.3) {
        self.colorView.backgroundColor = [UIColor greenColor];
    } else if (acceleration.x < -1.3) {
        self.colorView.backgroundColor = [UIColor orangeColor];
    } else if (acceleration.y > 1.3) {
        self.colorView.backgroundColor = [UIColor redColor];
    } else if (acceleration.y < -1.3) {
        self.colorView.backgroundColor = [UIColor blueColor];
    } else if (acceleration.z > 1.3) {
        self.colorView.backgroundColor = [UIColor yellowColor];
    } else if (acceleration.z < -1.3) {
        self.colorView.backgroundColor = [UIColor purpleColor];
    }
    
    double value = fabs(acceleration.x);
    if (value > 1.0) { value = 1.0;}
    self.colorView.alpha = value;
}

- (void)doRotation:(CMRotationRate)rotation {
    double value = (fabs(rotation.x)+fabs(rotation.y)+fabs(rotation.z))/8.0;
    if (value > 1.0) { value = 1.0;}
    self.colorView.alpha = value;
}


@end
