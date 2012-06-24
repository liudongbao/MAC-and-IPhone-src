//
//  SectionsAppDelegate.h
//  Sections
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SectionsViewController;

@interface SectionsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SectionsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SectionsViewController *viewController;

@end

