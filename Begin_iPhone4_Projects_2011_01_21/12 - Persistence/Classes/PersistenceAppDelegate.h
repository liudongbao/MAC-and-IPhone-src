//
//  PersistenceAppDelegate.h
//  Persistence
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistenceViewController;

@interface PersistenceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PersistenceViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PersistenceViewController *viewController;

@end

