//
//  IVBrickerViewController.m
//  IVBricker
//
//  Created by PJ Cabrera on 9/26/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "IVBrickerViewController.h"

@implementation IVBrickerViewController

@synthesize scoreLabel;
@synthesize ball;
@synthesize paddle;

- (void)dealloc {
    [scoreLabel release];
    [ball release];
    [super dealloc];
}

- (void) accelerometer:(UIAccelerometer *)accelerometer 
		 didAccelerate:(UIAcceleration *)accel
{
	float newX = paddle.center.x + (accel.x * 12);
	if(newX > 30 && newX < 290)
		paddle.center = CGPointMake( newX, paddle.center.y );
}

- (void)viewDidLoad {
    [super viewDidLoad];

	UIAccelerometer *theAccel = [UIAccelerometer sharedAccelerometer];
	theAccel.updateInterval = 1.0f / 30.0f;
	theAccel.delegate = self;
	
	ballMovement = CGPointMake(4,4);

	[self initializeTimer];
}

- (void)initializeTimer {
	float theInterval = 1.0f/30.0f;
    [NSTimer scheduledTimerWithTimeInterval:theInterval target:self 
								   selector:@selector(animateBall:) userInfo:nil repeats:YES];
}

- (void)animateBall:(NSTimer *)theTimer {
	ball.center = CGPointMake(ball.center.x+ballMovement.x,
		ball.center.y+ballMovement.y);
	
	if(ball.center.x > 300 || ball.center.x < 20)
		ballMovement.x = -ballMovement.x;
	if(ball.center.y > 440 || ball.center.y < 40)
		ballMovement.y = -ballMovement.y;
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
}

@end
