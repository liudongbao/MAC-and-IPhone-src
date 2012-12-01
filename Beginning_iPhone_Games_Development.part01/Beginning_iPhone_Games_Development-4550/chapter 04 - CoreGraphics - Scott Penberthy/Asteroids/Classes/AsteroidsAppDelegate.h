//
//  AsteroidsAppDelegate.h
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsteroidsViewController;

@interface AsteroidsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AsteroidsViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AsteroidsViewController *viewController;

@end

