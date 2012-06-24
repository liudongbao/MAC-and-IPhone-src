//
//  WhereAmIAppDelegate.h
//  WhereAmI
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WhereAmIViewController;

@interface WhereAmIAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WhereAmIViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WhereAmIViewController *viewController;

@end

