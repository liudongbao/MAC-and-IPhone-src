//
//  SystemSoundServicesAppDelegate.h
//  SystemSoundServices
//
//  Created by Eric Wing on 7/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SystemSoundServicesViewController;

@interface SystemSoundServicesAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow* mainWindow;
	SystemSoundServicesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow* mainWindow;
@property (nonatomic, retain) IBOutlet SystemSoundServicesViewController* viewController;

@end

