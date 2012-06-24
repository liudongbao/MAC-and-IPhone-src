//
//  SlowWorkerAppDelegate.h
//  SlowWorker
//
//  Created by Dave Mark on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlowWorkerViewController;

@interface SlowWorkerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SlowWorkerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SlowWorkerViewController *viewController;

@end

