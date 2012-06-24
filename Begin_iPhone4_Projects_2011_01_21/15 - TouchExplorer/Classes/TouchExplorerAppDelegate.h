//
//  TouchExplorerAppDelegate.h
//  TouchExplorer
//
//  Created by Dave Mark on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchExplorerViewController;

@interface TouchExplorerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TouchExplorerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TouchExplorerViewController *viewController;

@end

