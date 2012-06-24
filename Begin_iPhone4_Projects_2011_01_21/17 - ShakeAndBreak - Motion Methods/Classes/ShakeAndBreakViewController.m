//
//  ShakeAndBreakViewController.m
//  ShakeAndBreak
//
//  Created by JN on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShakeAndBreakViewController.h"

@implementation ShakeAndBreakViewController
@synthesize imageView;
@synthesize fixed;
@synthesize broken;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"glass" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    self.fixed = [UIImage imageNamed:@"home.png"];
    self.broken = [UIImage imageNamed:@"homebroken.png"]; 
    imageView.image = fixed;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.fixed = nil;
    self.broken = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [imageView release];
    [fixed release];
    [broken release];
    [super dealloc];
}

#pragma mark - 
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    imageView.image = fixed;
    brokenScreenShowing = NO;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        imageView.image = broken;
        AudioServicesPlaySystemSound(soundID);
        brokenScreenShowing = YES;
    }
}

@end
