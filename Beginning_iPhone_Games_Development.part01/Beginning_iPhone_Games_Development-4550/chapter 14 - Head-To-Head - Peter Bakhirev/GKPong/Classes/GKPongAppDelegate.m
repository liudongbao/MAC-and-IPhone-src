//
//  GKPongAppDelegate.m
//  GKPong
//
//  Created by Peter Bakhyryev on 6/12/09.
//  Copyright ByteClub LLC 2009. All rights reserved.
//

#import "GKPongAppDelegate.h"
#import "GKPongViewController.h"

@implementation GKPongAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
//  // test atan dump
//  float x = -5;
//  float y = 0;
//  float angle = atan2f(y, x) + M_PI;
//  float len = hypot(x, y);
//  NSLog( @"%f, %f : %f", x, y, angle);
//  NSLog( @"d: %f, %f", -(len * cos(angle)), -(len * sin(angle)));
//
//  x = -5; y = -4;
//  angle = atan2f(y, x) + M_PI;
//  len = hypot(x, y);
//  NSLog( @"%f, %f : %f", x, y, angle);
//  NSLog( @"d: %f, %f", -(len * cos(angle)), -(len * sin(angle)));
//
//  x = 0; y = -4;
//  angle = atan2f(y, x) + M_PI;
//  len = hypot(x, y);
//  NSLog( @"%f, %f : %f", x, y, angle);
//  NSLog( @"d: %f, %f", -(len * cos(angle)), -(len * sin(angle)));
//
//  x = 5; y = -4;
//  angle = atan2f(y, x) + M_PI;
//  len = hypot(x, y);
//  NSLog( @"%f, %f : %f", x, y, angle);
//  NSLog( @"d: %f, %f", -(len * cos(angle)), -(len * sin(angle)));
//
//  x = 5; y = 0;
//  angle = atan2f(y, x) + M_PI;
//  len = hypot(x, y);
//  NSLog( @"%f, %f : %f", x, y, angle);
//  NSLog( @"d: %f, %f", -(len * cos(angle)), -(len * sin(angle)));
          
    // Override point for customization after app launch
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
