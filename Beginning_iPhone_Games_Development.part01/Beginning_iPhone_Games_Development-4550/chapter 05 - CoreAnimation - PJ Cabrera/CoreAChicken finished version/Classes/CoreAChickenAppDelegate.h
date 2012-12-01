//
//  CoreAChickenAppDelegate.h
//  CoreAChicken
//
//  Created by PJ Cabrera on 10/3/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreAChickenViewController;

@interface CoreAChickenAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CoreAChickenViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CoreAChickenViewController *viewController;

@end

