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
@synthesize updateTimer;


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
    
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 1.0/10.0;
        [motionManager startAccelerometerUpdates];
    } else {
        accelerometerLabel.text = @"This device has no accelerometer.";
    }
    if (motionManager.gyroAvailable) {
        motionManager.gyroUpdateInterval = 1.0/10.0;
        [motionManager startGyroUpdates];
    } else {
        gyroscopeLabel.text = @"This device has no gyroscope.";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                        target:self
                                                      selector:@selector(updateDisplay) 
                                                      userInfo:nil 
                                                       repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.updateTimer = nil;
}

- (void)updateDisplay {
    if (motionManager.accelerometerAvailable) {
        CMAccelerometerData *accelerometerData = motionManager.accelerometerData;
        accelerometerLabel.text  = [NSString stringWithFormat:
									@"Accelerometer\n-----------\nx: %+.2f\ny: %+.2f\nz: %+.2f", 
									accelerometerData.acceleration.x, 
									accelerometerData.acceleration.y, 
									accelerometerData.acceleration.z];
    }
    if (motionManager.gyroAvailable) {
        CMGyroData *gyroData = motionManager.gyroData;
        gyroscopeLabel.text = [NSString stringWithFormat:
							   @"Gyroscope\n--------\nx: %+.2f\ny: %+.2f\nz: %+.2f", 
							   gyroData.rotationRate.x, 
							   gyroData.rotationRate.y, 
							   gyroData.rotationRate.z];
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
    [updateTimer release];
    [super dealloc];
}

@end
