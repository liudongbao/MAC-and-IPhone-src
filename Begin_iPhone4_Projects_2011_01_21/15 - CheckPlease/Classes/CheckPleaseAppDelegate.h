//
//  CheckPleaseAppDelegate.h
//  CheckPlease
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckPleaseViewController;

@interface CheckPleaseAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CheckPleaseViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CheckPleaseViewController *viewController;

@end

