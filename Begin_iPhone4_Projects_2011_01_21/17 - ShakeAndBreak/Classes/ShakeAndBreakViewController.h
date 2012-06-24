//
//  ShakeAndBreakViewController.h
//  ShakeAndBreak
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

#define kAccelerationThreshold       1.7
#define kUpdateInterval              (1.0f/10.0f)

@interface ShakeAndBreakViewController :
UIViewController <UIAccelerometerDelegate> {
    UIImageView *imageView;
	
    CMMotionManager *motionManager;
    BOOL brokenScreenShowing;
    SystemSoundID soundID;
    UIImage *fixed;
    UIImage *broken;
}
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIImage *fixed;
@property (nonatomic, retain) UIImage *broken;
@end

