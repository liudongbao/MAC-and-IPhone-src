//
//  CoreAChickenViewController.m
//  CoreAChicken
//
//  Created by PJ Cabrera on 10/3/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "CoreAChickenViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CoreAChickenViewController

@synthesize animateButton;
@synthesize firstView;
@synthesize secondView;
@synthesize theChicken;
@synthesize theRoad;

- (void)dealloc {
	[animateButton release];
	[firstView release];
	[secondView release];
	[theChicken release];
	[theRoad release];
    [super dealloc];
}

- (void)viewAnimation1 {
	[UIView beginAnimations:@"viewAnimation1" context:theChicken];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:
	 @selector(animationDidStop:finished:context:)];
	
	theChicken.frame = CGRectMake(15, 330, 62, 90);

	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)theAnimation finished:(BOOL)flag 
				 context:(void *)context 
{
	animateButton.enabled = YES;
}

- (void)viewAnimation2 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
	theChicken.frame = CGRectMake(15, 144, 62, 90);
	
	[UIView commitAnimations];
}

- (void)animationDidStop {
	animateButton.enabled = YES;
}

- (void)viewAnimation3 {
	[UIView beginAnimations:@"viewAnimation3" context:theRoad];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.5];
	
	[UIView setAnimationRepeatAutoreverses:YES];
	[UIView setAnimationRepeatCount:2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:
	 @selector(theRoadAnimationDidStop:finished:context:)];
	
	theRoad.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)theRoadAnimationDidStop:(NSString *)theAnimation finished:(BOOL)flag 
						context:(void *)context 
{
	((UIView *)context).alpha = 1.0;
	animateButton.enabled = YES;
}

- (void)viewAnimation4 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:0.5];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	[UIView setAnimationRepeatAutoreverses:YES];
	[UIView setAnimationRepeatCount:2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:
	 @selector(resetTheChickenProperties)];
	
	theChicken.frame = CGRectMake(15, 330, 62, 90);
	[UIView commitAnimations];
}

- (void)resetTheChickenProperties {
	theChicken.transform = CGAffineTransformIdentity;
	theChicken.frame = CGRectMake(15, 144, 62, 90);
	animateButton.enabled = YES;
}

- (void)viewAnimation5 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
	theChicken.frame = CGRectMake(235, 144, 62, 90);
	[UIView commitAnimations];
}

- (void)viewAnimation6 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
	theChicken.transform = CGAffineTransformMakeScale(1.25, 1.25);
	[UIView commitAnimations];
}

- (void)viewAnimation7 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
	CGAffineTransform transform1 = CGAffineTransformMakeScale(1, 1);
	CGAffineTransform transform2 = 
		CGAffineTransformMakeRotation(179.9 * M_PI / 180.0);
	theChicken.transform = CGAffineTransformConcat(transform1, transform2);
	[UIView commitAnimations];
}

- (void)viewAnimation8 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:
	 @selector(resetTheChickenProperties)];
	
	CGAffineTransform transform1 = 
		CGAffineTransformMakeTranslation(-220, 0);
	theChicken.transform = 
		CGAffineTransformRotate(transform1, 359.9 * M_PI / 180.0);
	[UIView commitAnimations];
}

- (void)viewAnimation9 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp 
					forView:self.view cache:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
    firstView.hidden = YES;
    secondView.hidden = NO;
	[UIView commitAnimations];
}

- (void)viewAnimation10 {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft 
					forView:self.view cache:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
    firstView.hidden = NO;
    secondView.hidden = YES;
	[UIView commitAnimations];
}

- (IBAction)animate {
	static int counter = 0;

	switch (++counter) {
		case 1:
			[self viewAnimation1];
			break;
		case 2:
			[self viewAnimation2];
			break;
		case 3:
			[self viewAnimation3];
			break;
		case 4:
			[self viewAnimation4];
			break;
		case 5:
			[self viewAnimation5];
			break;
		case 6:
			[self viewAnimation6];
			break;
		case 7:
			[self viewAnimation7];
			break;
		case 8:
			[self viewAnimation8];
			break;
		case 9:
			[self viewAnimation9];
			break;
		default:
			[self viewAnimation10];
			counter = 0;
			break;
	}
	animateButton.enabled = NO;
}

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
}

@end
