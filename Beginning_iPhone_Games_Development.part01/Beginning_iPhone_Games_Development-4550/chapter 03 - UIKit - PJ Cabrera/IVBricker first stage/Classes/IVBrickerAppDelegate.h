//
//  IVBrickerAppDelegate.h
//  IVBricker
//
//  Created by PJ Cabrera on 9/12/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IVBrickerViewController;

@interface IVBrickerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IVBrickerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet IVBrickerViewController *viewController;

@end

