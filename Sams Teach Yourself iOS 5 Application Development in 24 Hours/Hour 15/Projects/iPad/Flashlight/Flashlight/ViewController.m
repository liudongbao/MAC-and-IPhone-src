//
//  ViewController.m
//  Flashlight
//
//  Created by John Ray on 9/15/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"
#define kOnOffToggle @"onOff"
#define kBrightnessLevel @"brightness"

@implementation ViewController
@synthesize toggleSwitch;
@synthesize brightnessSlider;
@synthesize lightSource;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.brightnessSlider.value = [userDefaults floatForKey:kBrightnessLevel];
    self.toggleSwitch.on = [userDefaults boolForKey:kOnOffToggle];
    if ([userDefaults boolForKey: kOnOffToggle]) {
        self.lightSource.alpha = [userDefaults floatForKey:kBrightnessLevel];
    } else {
        self.lightSource.alpha = 0.0;
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setToggleSwitch:nil];
    [self setBrightnessSlider:nil];
    [self setLightSource:nil];
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

- (IBAction)setLightSourceAlphaValue:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   [userDefaults setBool:self.toggleSwitch.on forKey:kOnOffToggle];
    [userDefaults setFloat:self.brightnessSlider.value
                    forKey:kBrightnessLevel];
    [userDefaults synchronize];
 
    if (self.toggleSwitch.on) {
        self.lightSource.alpha = self.brightnessSlider.value;
    } else {
        self.lightSource.alpha = 0.0;
    }
}

@end
