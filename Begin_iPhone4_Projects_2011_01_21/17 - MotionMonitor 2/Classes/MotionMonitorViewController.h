//
//  MotionMonitorViewController.h
//  MotionMonitor
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface MotionMonitorViewController : UIViewController {
    CMMotionManager *motionManager;
    UILabel *accelerometerLabel;
    UILabel *gyroscopeLabel;
    NSTimer *updateTimer;
}

@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) IBOutlet UILabel *accelerometerLabel;
@property (nonatomic, retain) IBOutlet UILabel *gyroscopeLabel;

@property (retain) NSTimer *updateTimer;
@end

