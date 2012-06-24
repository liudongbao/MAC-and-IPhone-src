//
//  BallViewController.h
//  Ball
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define kUpdateInterval    (1.0f/60.0f)

@interface BallViewController : UIViewController {
    CMMotionManager *motionManager;
}
@property (nonatomic, retain) CMMotionManager *motionManager;
@end
