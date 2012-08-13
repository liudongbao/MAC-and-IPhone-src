//
//  ViewController.m
//  Orientation
//
//  Created by John Ray on 9/4/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize orientationLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(orientationChanged:) 
     name:@"UIDeviceOrientationDidChangeNotification" 
     object:nil];
    
    [super viewDidLoad];
}

- (void)orientationChanged:(NSNotification *)notification {
    
    UIDeviceOrientation orientation;
    orientation = [[UIDevice currentDevice] orientation];
    
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
            self.orientationLabel.text=@"Face Up";        
            break;
        case UIDeviceOrientationFaceDown:
            self.orientationLabel.text=@"Face Down";
            break;
        case UIDeviceOrientationPortrait:
            self.orientationLabel.text=@"Standing Up";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.orientationLabel.text=@"Upside Down";
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.orientationLabel.text=@"Left Side";
            break;
        case UIDeviceOrientationLandscapeRight:
            self.orientationLabel.text=@"Right Side";
            break;
        default:
            self.orientationLabel.text=@"Unknown";
            break;
    }
}

- (void)viewDidUnload
{
    [self setOrientationLabel:nil];
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
