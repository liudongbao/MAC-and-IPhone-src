//
//  State_LabAppDelegate.h
//  State Lab
//
//  Created by Dave Mark on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class State_LabViewController;

@interface State_LabAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    State_LabViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet State_LabViewController *viewController;

@end

