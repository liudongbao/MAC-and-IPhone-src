//
//  ShakeAndBreakViewController.m
//  ShakeAndBreak
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShakeAndBreakViewController.h"

@implementation ShakeAndBreakViewController
@synthesize motionManager;
@synthesize imageView;
@synthesize fixed;
@synthesize broken;

- (void) viewDidLoad {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"glass"
                                                     ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL
                                                fileURLWithPath:path], &soundID);
    self.fixed = [UIImage imageNamed:@"home.png"];
    self.broken = [UIImage imageNamed:@"homebroken.png"];
    
    imageView.image = fixed;
	
    self.motionManager = [[[CMMotionManager alloc] init] autorelease];
    motionManager.accelerometerUpdateInterval = kUpdateInterval;
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [motionManager startAccelerometerUpdatesToQueue:queue
                                        withHandler:
     ^(CMAccelerometerData *accelerometerData, NSError *error){
		 if (error) {
			 [motionManager stopAccelerometerUpdates];
		 } else {
			 if (!brokenScreenShowing) {
				 CMAcceleration acceleration = accelerometerData.acceleration;
				 if (acceleration.x > kAccelerationThreshold
					 || acceleration.y > kAccelerationThreshold
					 || acceleration.z > kAccelerationThreshold) {
					 [imageView performSelectorOnMainThread:@selector(setImage:)
												 withObject:broken
											  waitUntilDone:NO];
					 AudioServicesPlaySystemSound(soundID);
					 brokenScreenShowing = YES;
				 }
			 }
		 }
	 }];
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
    self.motionManager = nil;
    self.imageView = nil;
    self.fixed = nil;
    self.broken = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [motionManager release];
    [imageView release];
    [fixed release];
    [broken release];
    [super dealloc];
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    imageView.image = fixed;
    brokenScreenShowing = NO;
}

@end
