//
//  LocalizeMeAppDelegate.h
//  LocalizeMe
//
//  Created by JN on 10/29/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalizeMeViewController;

@interface LocalizeMeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LocalizeMeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet LocalizeMeViewController *viewController;

@end
