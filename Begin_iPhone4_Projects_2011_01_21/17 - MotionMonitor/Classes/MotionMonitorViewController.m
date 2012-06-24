//
//  MotionMonitorViewController.m
//  MotionMonitor
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MotionMonitorViewController.h"

@implementation MotionMonitorViewController
@synthesize motionManager;
@synthesize accelerometerLabel;
@synthesize gyroscopeLabel;



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
    self.motionManager = [[[CMMotionManager alloc] init] autorelease];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 1.0/10.0;
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:
		 ^(CMAccelerometerData *accelerometerData, NSError *error){
			 NSString *labelText;
			 if (error) {
				 [motionManager stopAccelerometerUpdates];
				 labelText = [NSString stringWithFormat:
							  @"Accelerometer encountered error: %@", error];
			 } else {
				 labelText = [NSString stringWithFormat:
							  @"Accelerometer\n-----------\nx: %+.2f\ny: %+.2f\nz: %+.2f", 
							  accelerometerData.acceleration.x, 
							  accelerometerData.acceleration.y, 
							  accelerometerData.acceleration.z];
			 }
			 [accelerometerLabel performSelectorOnMainThread:@selector(setText:) 
												  withObject:labelText 
											   waitUntilDone:YES];
		 }];
    } else {
        accelerometerLabel.text = @"This device has no accelerometer.";
    }
    if (motionManager.gyroAvailable) {
        motionManager.gyroUpdateInterval = 1.0/10.0;
        [motionManager startGyroUpdatesToQueue:queue withHandler:
		 ^(CMGyroData *gyroData, NSError *error) {
			 NSString *labelText;
			 if (error) {
				 [motionManager stopGyroUpdates];
				 labelText = [NSString stringWithFormat:
							  @"Gyroscope encountered error: %@", error];
			 } else {
				 labelText = [NSString stringWithFormat:
							  @"Gyroscope\n--------\nx: %+.2f\ny: %+.2f\nz: %+.2f", 
							  gyroData.rotationRate.x, 
							  gyroData.rotationRate.y, 
							  gyroData.rotationRate.z];
			 }
			 [gyroscopeLabel performSelectorOnMainThread:@selector(setText:) 
											  withObject:labelText 
										   waitUntilDone:YES];
		 }];
    } else {
        gyroscopeLabel.text = @"This device has no gyroscope";
    }
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
    self.motionManager = nil;
    self.accelerometerLabel = nil;
    self.gyroscopeLabel = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [motionManager release];
    [accelerometerLabel release];
    [gyroscopeLabel release];
    [super dealloc];
}

@end
