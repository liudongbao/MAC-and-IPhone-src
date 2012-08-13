//
//  ViewController.h
//  Cupertino
//
//  Created by John Ray on 9/19/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    SystemSoundID soundStraight;
    SystemSoundID soundRight;
    SystemSoundID soundLeft;
    int lastSound;
}

@property (strong, nonatomic) CLLocationManager *locMan;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIView *waitView;
@property (strong, nonatomic) IBOutlet UIView *distanceView;
@property (strong, nonatomic) IBOutlet UIImageView *directionArrow;
@property (strong, nonatomic) CLLocation *recentLocation;


-(double)headingToLocation:(CLLocationCoordinate2D)desired
                   current:(CLLocationCoordinate2D)current;

@end
