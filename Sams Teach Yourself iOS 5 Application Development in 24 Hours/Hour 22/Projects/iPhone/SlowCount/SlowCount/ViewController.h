//
//  ViewController.h
//  SlowCount
//
//  Created by John Ray on 9/21/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    int count;
    UIBackgroundTaskIdentifier counterTask;
}

@property (strong, nonatomic) IBOutlet UILabel *theCount;
@property (strong, nonatomic) NSTimer *theTimer;

- (void)countUp;

@end
