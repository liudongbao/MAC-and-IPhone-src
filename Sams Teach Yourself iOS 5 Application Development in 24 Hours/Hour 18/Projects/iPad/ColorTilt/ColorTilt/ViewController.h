//
//  ViewController.h
//  ColorTilt
//
//  Created by John Ray on 9/4/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *colorView;
@property (strong, nonatomic) IBOutlet UISwitch *toggleAccelerometer;
@property (strong, nonatomic) IBOutlet UISwitch *toggleGyroscope;
@property (strong, nonatomic) CMMotionManager *motionManager;

- (IBAction)controlHardware:(id)sender;
- (void)doAcceleration:(CMAcceleration)acceleration;
- (void)doRotation:(CMRotationRate)rotation;

@end
